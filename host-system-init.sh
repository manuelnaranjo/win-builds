#!/bin/false

echo ${ARCH} ${SYSTEM_COPY} ${SYSTEM} ${LIB} > /dev/null

# When building the cross-compiler host system, a binary of yypkg is needed.
YYPKG_SRC="/home/adrien/projects/yypkg/src"
YYPKG_HST="${YYPKG_SRC}/yypkg.native"

# When building the cross-compiler host system, the location of the slackware
# binary packages
YYOS_OUTPUT="${CWD}/yy_of_slack/tmp/output-${ARCH}"

# The script mounts several filesystems; these variables keep track of what is
# mounted in order to always umount everything on exit
BIND_MOUNTED_DIRS=""
SPECIAL_FILESYSTEMS=""

if [ "${ARCH}" = "i486" ]; then
  YYPKG_TGT="${PWD}/i486/yypkg.native"
  MAKEYPKG_TGT="${PWD}/i486/makeypkg.native"
  BSDTAR_TGT="${PWD}/i486/bsdtar"
  FOO="/home/adrien/t/sbchroot/slackware-current/"
else
  YYPKG_TGT="${YYPKG_SRC}/yypkg.native"
  MAKEYPKG_TGT="${YYPKG_SRC}/makeypkg.native"
  BSDTAR_TGT="$(which bsdtar)"
  FOO="/"
fi

umounts() {
  if [ -n "${BIND_MOUNTED_DIRS}" -o -n "${SPECIAL_FILESYSTEMS}" ]; then
    umount ${BIND_MOUNTED_DIRS} ${SPECIAL_FILESYSTEMS}
    BIND_MOUNTED_DIRS=""
    SPECIAL_FILESYSTEMS=""
  fi
}

mount_bind() {
  old="$1"
  new="$2"
  mkdir -p "${new}"
  mount --bind "${old}" "${new}"
  BIND_MOUNTED_DIRS="${new} ${BIND_MOUNTED_DIRS}"
}

mount_dev_pts_and_procfs() {
  BASE="${1}"
  mkdir -p "${BASE}/proc" "${BASE}/dev/pts"
  mount -t proc proc "${BASE}/proc"
  SPECIAL_FILESYSTEMS="${BASE}/proc ${SPECIAL_FILESYSTEMS}"
  mount -t devpts devpts "${BASE}/dev/pts"
  SPECIAL_FILESYSTEMS="${BASE}/dev/pts ${SPECIAL_FILESYSTEMS}"
}

populate_slash_dev() {
  mkdir ${SYSTEM_COPY}/dev
  mkdir ${SYSTEM_COPY}/dev/pts
  mknod ${SYSTEM_COPY}/dev/console c 5 1
  mknod ${SYSTEM_COPY}/dev/null c 1 3
  mknod ${SYSTEM_COPY}/dev/zero c 1 5
  chmod 666 ${SYSTEM_COPY}/dev/null ${SYSTEM_COPY}/dev/zero
}

# copy_ld_so: install the base libc files inside the chroot
copy_ld_so() {
  ARCHIVE="$(find "${YYOS_OUTPUT}" -maxdepth 1 -name "glibc-2.*.txz" -printf '%f\n')"
  VER="$(echo "${ARCHIVE}" |sed -e 's/^glibc-\(2\.[0-9]\+\).*/\1/')"
  mkdir -p "${SYSTEM_COPY}/${LIB}"
  bsdtar xf "${YYOS_OUTPUT}/${ARCHIVE}" -q -C ${SYSTEM_COPY}/${LIB} \
    --strip-components=3 "package-glibc/${LIB}/incoming/ld-${VER}.so"
  if [ ${ARCH} = "x86_64" ]; then
    ln -s ld-${VER}.so ${SYSTEM_COPY}/${LIB}/ld-linux-x86-64.so.2
  else
    ln -s ld-${VER}.so ${SYSTEM_COPY}/${LIB}/ld-linux.so.2
  fi
}

INITDIR="/tmp/yypkg_init" # temp directory
INITDIR_FULL="${SYSTEM_COPY}/${INITDIR}" # absolute path; outside the chroot

# Init yypkg's installation in /
YYPREFIX="${SYSTEM_COPY}" "${YYPKG_HST}" -init

mkdir -p ${INITDIR_FULL}/pkgs

trap umounts EXIT SIGINT ERR

for dir in bin ${LIB} usr/${LIB}; do
  mount_bind "${FOO}${dir}" "${INITDIR_FULL}/host/${dir}"
done

rsync --archive "${YYOS_OUTPUT}/" "${INITDIR_FULL}/pkgs/"

populate_slash_dev

copy_ld_so

for bin in "${YYPKG_TGT}" "${MAKEYPKG_TGT}" "${BSDTAR_TGT}"; do
  bin_basename="$(basename "${bin}")"
  cp "${bin}" "${SYSTEM_COPY}/sbin/${bin_basename%.native}"
done

# Install all packages
find "${INITDIR_FULL}/pkgs" -maxdepth 1 -name '*.txz' -printf '%f\n' \
  | while read PKG; do
    echo "Installing ${PKG}";
    YYPREFIX="/" \
      LANG="en_US.UTF-8" \
      PATH="${INITDIR}/host/bin:${PATH}" \
      LD_LIBRARY_PATH="${INITDIR}/host/${LIB}:${INITDIR}/host/usr/${LIB}" \
      chroot "${SYSTEM_COPY}" "/sbin/yypkg" "-install" "${INITDIR}/pkgs/${PKG}" || true
done

umounts

rm -r ${SYSTEM_COPY}/tmp/yypkg_init ${SYSTEM_COPY}/tmp/.{ICE,X11}-unix

for bin in cc c++ {${ARCH}-slackware-linux-,}{gcc,g++}; do
  ln -s "/usr/bin/ccache" "${SYSTEM_COPY}/usr/local/bin/${bin}"
done

cp -r --preserve="mode,timestamps" "${SYSTEM_COPY}" "${SYSTEM}"