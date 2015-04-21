let builder ~cross ~name ~host =
  let open Config in
  let build = Arch.slackware in
  let prefix = Prefix.t ~build ~host ~target:host in
  let logs, yyoutput = Builder.logs_yyoutput ~nickname:prefix.Prefix.nickname in
  cross.Config.Builder.target_prefix <- Some prefix.Prefix.yyprefix;
  let open Arch in
  let open Prefix in
  let open Builder in
  {
    name;
    prefix; logs; yyoutput;
    path = Env.Prepend [ bindir cross.prefix; bindir Native_toolchain.builder.prefix ];
    pkg_config_path = Env.Clear;
    pkg_config_libdir = Env.Set [ Filename.concat prefix.libdir "pkgconfig" ] ;
    tmp = Env.Set [ Filename.concat prefix.Prefix.yyprefix "tmp" ];
    target_prefix = None;
    cross_prefix  = Some cross.Config.Builder.prefix.Prefix.yyprefix;
    native_prefix = Some Native_toolchain.builder.prefix.Prefix.yyprefix;
    packages = [];
  }

let do_adds builder =
  let open Common in
  let add_full = Config.Builder.register ~builder in
  let add = add_full ?outputs:None in

  let xz_add ~variant ~dependencies =
    add ("xz", Some variant)
      ~dir:"slackware64-current/a"
      ~dependencies
      ~version:"5.0.5"
      ~build:(if variant = "regular" then 1 else -1)
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "56f1d78117f0c32bbb1cfd40117aa7f55bee8765";
      ]
  in

  let libarchive_add ~variant ~dependencies =
    add ("libarchive", Some variant)
      ~dir:"slackware64-current/l"
      ~dependencies
      ~version:"3.1.2"
      ~build:(if variant = "regular" then 1 else -1)
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "6a991777ecb0f890be931cec4aec856d1a195489";
        "0001-windows-don-t-undef-stat-since-it-my-be-defined-to-s.patch", "";
        "use-static-asserts-to-guarantee-abi-compatibility.patch", "";
      ]
  in

  let efl ~variant ~dependencies =
    add ("efl", Some variant)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies
      ~version:Version.efl
      ~build:2
      ~sources:[
        Source.efl;
        (* "0001-Ecore_Win32-Fix-string-for-the-BackSpace-key-on-Wind.patch", ""; *)
      ]
  in

  let elementary ~variant ~dependencies =
    add ("elementary", Some variant)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies
      ~version:Version.elementary
      ~build:2
      ~sources:[
        Source.elementary
      ]
  in

  let libjpeg ~variant ~dependencies =
    add ("libjpeg", Some variant)
      ~dir:"slackware64-current/l"
      ~dependencies
      ~version:"v9a"
      ~build:2
      ~sources:[
        "jpegsrc.${VERSION}.tar.gz", "d65ed6f88d318f7380a3a5f75d578744e732daca";
      ]
  in

  let zlib ~variant ~dependencies =
    add ("zlib", Some variant)
      ~dir:"slackware64-current/l"
      ~dependencies
      ~version:"1.2.8"
      ~build:1
      ~sources:[
        "zlib-${VERSION}.tar.xz", "961458ab8407e6192143b5f886ed8891e0def181";
      ]
  in

  let bzip2 = add ("bzip2", None)
      ~dir:"slackware64-current/a"
      ~dependencies: []
      ~version:"1.0.6"
      ~build:1
      ~sources:[
      "bzip2-${VERSION}.tar.gz", "3f89f861209ce81a6bab1fd1998c0ef311712002";
      ]
  in


  let lua ~variant ~dependencies =
    add ("lua", Some variant)
      ~dir:"slackbuilds.org/development"
      ~dependencies
      ~version:"5.1.5"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "b3882111ad02ecc6b972f8c1241647905cb2e3fc";
        "${PACKAGE}.pc", "";
        "src_makefile", "";
      ]
  in

  let freetype ~variant ~dependencies =
    add ("freetype", Some variant)
      ~dir:"slackware64-current/l"
      ~dependencies
      ~version:"2.5.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "6c6455e5a58b2af56f0a403be0769b6dd47f6d1b";
        "freetype.illadvisederror.diff.gz", "";
        "freetype.subpixel.rendering.diff.gz", "";
      ]
  in

  let expat ~variant ~dependencies =
    add ("expat", Some variant)
      ~dir:"slackware64-current/l"
      ~dependencies
      ~version:"2.1.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "d739f9afeaf11fe231cbb0f684b69c7ba7dc11b7";
      ]
  in

  let dbus_add ~variant ~dependencies =
    add ("dbus", Some variant)
      ~dir:"slackware64-current/a"
      ~dependencies
      ~version:"1.6.28"
      ~build:(if variant = "regular" then 1 else -1)
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "cc8fd21f2123a58ad78c4e50c8f5b330a39cc21f";
      ]
  in

  let harfbuzz_add ~variant ~dependencies =
    add ("harfbuzz", Some variant)
      ~dir:"slackware64-current/l"
      ~dependencies
      ~version:"0.9.16"
      ~build:(if variant = "regular" then 2 else -1)
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "d7fa8ef7f2eca07e29d94f448f6196c9b3022d64";
      ]
  in

  let fontconfig_add ~variant ~dependencies =
    add ("fontconfig", Some variant)
      ~dir:"slackware64-current/x"
      ~dependencies
      ~version:"2.11.1"
      ~build:(if variant = "regular" then 1 else -1)
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "4f83bab1834f60345f1ef3920ac393d9f9c609ab";
      ]
  in

  let _all =
    let mingw_w64_tool_add name = add (name, None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:Version.mingw_w64
      ~build:1
      ~sources:[
        Source.mingw_w64
      ]
    in

    let mingw_w64 = add ("mingw-w64", Some "full")
      ~dir:"mingw"
      ~dependencies:[]
      ~version:Version.mingw_w64
      ~build:2
      ~sources:[
        Source.mingw_w64;
        "0001-intrinsics-don-t-include-d-f-i-vec.h-from-inside-int.patch", "";
      ]
    in

    let winpthreads = add ("winpthreads", None)
      ~dir:"mingw"
      ~dependencies:[ mingw_w64 ]
      ~version:Version.mingw_w64
      ~build:2
      ~sources:[
        Source.mingw_w64;
      ]
    in

    let gendef = mingw_w64_tool_add "gendef" in

    let genidl = mingw_w64_tool_add "genidl" in

    let genpeimg = mingw_w64_tool_add "genpeimg" in

    let widl = mingw_w64_tool_add "widl" in

    let libmangle = mingw_w64_tool_add "libmangle" in

    let winstorecompat = mingw_w64_tool_add "winstorecompat" in

    let win_iconv = add ("win-iconv", None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"0.0.6"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "51ce281cd8ce2debf3226482e86e0e534141ed01";
      ]
    in

    let gettext = add ("gettext", None)
      ~dir:"slackware64-current/a"
      ~dependencies:[ win_iconv ]
      ~version:"0.18.3.1"
      ~build:2
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "a32c19a6e39450748f6e56d2ac6b8b0966a5ab05";
      ]
    in

    let xz = xz_add ~variant:"regular" ~dependencies:[ gettext ] in

    let zlib = zlib ~variant:"regular" ~dependencies:[] in

    let libjpeg = libjpeg ~variant:"regular" ~dependencies:[] in

    let expat = expat ~variant:"regular" ~dependencies:[] in

    let libpng = add ("libpng", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ zlib ]
      ~version:"1.4.14"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "402271bcd9af622e2f3ff378d57cd73c2dda7ad5";
      ]
    in

    let freetype = freetype ~variant:"regular" ~dependencies:[ zlib; libpng ] in

    let fontconfig = fontconfig_add ~variant:"regular" ~dependencies:[ freetype; expat ] in

    let giflib = add ("giflib", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"4.1.6"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "b38d1f77afb1ea554acadeb3401cb34c6b8bf16b";
      ]
    in

    let libtiff = add ("libtiff", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ libjpeg ]
      ~version:"3.9.7"
      ~build:1
      ~sources:[
        "tiff-${VERSION}.tar.xz", "92dd9600b3b7c0a1ec7a8b1d790c089cfe30ff2c";
        "tiff-${VERSION}_CVE-2012-4447_CVE-2012-4564_CVE-2013-1960_CVE-2013-1961.diff.gz", "";
        "tiff-${VERSION}_CVE-2013-4231.diff.gz", "";
        "tiff-${VERSION}_CVE-2013-4232.diff.gz", "";
        "tiff-${VERSION}_CVE-2013-4244.diff.gz", "";
      ]
    in

    let lua = lua ~variant:"regular" ~dependencies:[] in

    let ca_certificates = add ("ca-certificates", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[]
      ~version:"20130906"
      ~build:1
      ~sources:[
        "${PACKAGE}_${VERSION}.tar.gz", "7f197c1bf7c7fc82e9f8f2fec6d8cc65f6a6187b";
      ]
    in

    let openssl = add ("openssl", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[ ca_certificates ]
      ~version:"1.0.1l"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "4547a0b4269acf76b1f9e7d188896867d6fc8c18";
      ]
    in

    let gmp = add ("gmp", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"5.1.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "12cfe0911d64fcbd85835df9ddc18c99af8f9a45";
      ]
    in

    let nettle = add ("nettle", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[]
      ~version:"2.7.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "48dac2b55a07e6cf4ebf74d069f0c26e7019ce99";
      ]
    in

    let libtasn1 = add ("libtasn1", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"3.6"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "5d480b83526264a216b5822c2dcbffad26a792d9";
      ]
    in

    let gnutls = add ("gnutls", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[ zlib; gmp; libtasn1; nettle; ca_certificates ]
      ~version:"3.2.15"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "31f289b48b0bf054f5f8c16d3b878615d0ae06fc";
      ]
    in

    let curl = add ("curl", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[ ca_certificates ]
      ~version:"7.39.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.lzma", "a72fa6615d112960be609cdcf720f6332da822db";
      ]
    in

    let c_ares = add ("c-ares", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"1.10.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "e44e6575d5af99cb3a38461486e1ee8b49810eb5";
      ]
    in

    let pixman = add ("pixman", None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"0.32.6"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "d136a0007e9bd24841a5324b01ce867892f997c7";
      ]
    in

    let libffi = add ("libffi", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"3.0.13"
      ~build:2
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "03589fae4c732585476f5d93f691bbc446187ef7";
      ]
    in

    let glib2 = add ("glib2", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ libffi; gettext ]
      ~version:"2.42.1"
      ~build:1
      ~sources:[
        "glib-${VERSION}.tar.xz", "b5158fd434f01e84259155c04ff93026a090e586";
      ]
    in

    let cairo = add ("cairo", None)
      ~dir:"slackware64-current/l"
      (* TODO: seems to be able to use pthread *)
      ~dependencies:[ pixman; freetype; fontconfig; libpng ]
      ~version:"1.12.18"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "a76940b58da9c83b8934264617135326c0918f9d";
      ]
    in

    let atk = add ("atk", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"2.8.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "e8a9dacd22b31a6cb733ce66fb1c220cc6720970";
      ]
    in

    let pango = add ("pango", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"1.34.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "a6c224424eb3f0dcc231a8000591c05a85df689c";
      ]
    in

    let gdk_pixbuf2 = add ("gdk-pixbuf2", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ glib2 ]
      ~version:"2.30.8"
      ~build:1
      ~sources:[
        "gdk-pixbuf-${VERSION}.tar.xz", "6277b4e5b5e334b3669f15ae0376e184be9e8cd8";
        "gdk-pixbuf.pnglz.diff.gz", "";
      ]
    in

    let gtk_2 = add ("gtk+2", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ gdk_pixbuf2; pango; atk; cairo; glib2 ]
      ~version:"2.24.25"
      ~build:1
      ~sources:[
        "gtk+-${VERSION}.tar.xz", "017ee13f172a64026c4e77c3744eeabd5e017694";
        "gtk+-2.24.x.icon-compat.am.diff.gz", "";
        "gtk+-2.24.x.icon-compat.diff.gz", "";
      ]
    in

    let glib_networking = add ("glib-networking", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ glib2 ]
      ~version:"2.36.2"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "d4c2accd50ff4769f434cd552734fb2b0b2b3b81";
      ]
    in

    let libxml2 = add ("libxml2", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ zlib; xz ]
      ~version:"2.9.2"
      ~build:2
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "f46a37ea6d869f702e03f393c376760f3cbee673";
      ]
    in

    let sqlite = add ("sqlite", None)
      ~dir:"slackware64-current/ap"
      ~dependencies:[]
      ~version:"3071700"
      ~build:1
      ~sources:[
        "${PACKAGE}-src-3071700.tar.xz", "eb5e12337d29ce2da9a9ed9b1d69f6c66c2e4877";
        "COPYRIGHT.gz", "";
        "configure.ac", "";
      ]
    in

    let libsoup = add ("libsoup", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ glib2; sqlite ]
      ~version:"2.42.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "252424b83e395716beca4ea2ef78944826e83873";
        "libsoup-2.42.3.1-fix-build-without-ntml.patch", "";
      ]
    in

    let icu4c = add ("icu4c", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"51.2" (* NOTE: the version number in sources needs updating too *)
      ~build:2
      ~sources:[
        "${PACKAGE}-51_2-src.tar.xz", "c50ed0a3870478d81ac5f7d765619f83e9be6032";
      ]
    in

    let gperf = add ("gperf", None)
      ~dir:"slackware64-current/d"
      ~dependencies:[]
      ~version:"3.0.4"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "78ea1a5660538bfa35bb5ccec9b18a0ec68e9e87";
      ]
    in

    let mpfr = add ("mpfr", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"3.1.2"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "03e593cc6e26639ef5e60be1af8dc527209e5172";
      ]
    in

    let libmpc = add ("libmpc", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"0.8.2"
      ~build:2
      ~sources:[
        "mpc-${VERSION}.tar.xz", "1a8a84a04aef025b690cbbdd299e745dd7416514";
      ]
    in

    let libogg = add ("libogg", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"1.3.2"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "5e525ec6a4135066932935c01d2c309ea5009f8d";
      ]
    in

    let libvorbis = add ("libvorbis", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ libogg ]
      ~version:"1.3.4"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "b99724acdf3577982b3146b9430d765995ecf9e1";
      ]
    in

    let libtheora = add ("libtheora", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ libvorbis ]
      ~version:"1.1.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "800aa48cf9e59d546c18ecdac1d06d7643cbb2d3";
      ]
    in

    let fribidi = add ("fribidi", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"0.19.6"
      ~build:3
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "5a6ff82fdee31d27053c39e03223666ac1cb7a6a";
      ]
    in

    let check = add ("check", None)
      ~dir:"slackbuilds.org/development"
      ~dependencies:[]
      ~version:"0.9.14"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "4b79e2d485d014ddb438e322b64235347d57b0ff";
      ]
    in

    let dbus = dbus_add ~variant:"regular" ~dependencies:[ expat ] in

    let harfbuzz = harfbuzz_add
      ~variant:"regular"
      (* TODO: the cairo dependency is only build-time and the glib2 and icu4c
       * ones are probably dlopen()'ed *)
      ~dependencies:[ cairo; freetype; glib2; icu4c; libpng ]
    in

    let pkg_config = add ("pkg-config", None)
      ~dir:"slackware64-current/d"
      ~dependencies:[]
      ~version:"0.25"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "d2e75fcdbda33cf1577a76b7b2beaa408f2aa299";
      ]
    in

    let libarchive = libarchive_add ~variant:"regular" ~dependencies:[ nettle ] in

    let wget = add ("wget", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[ openssl; (* probably pcre too, for after 1.5 *) ]
      ~version:"1.14"
      ~build:3
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "cfa0906e6f72c1c902c29b52d140c22ecdcd617e";
      ]
    in

    let binutils = add ("binutils", None)
      ~dir:"slackware64-current/d"
      ~dependencies:[]
      ~version:Version.binutils
      ~build:2
      ~sources:[
        Source.binutils;
        "binutils.export.demangle.h.diff.gz", "";
        "binutils.no-config-h-check.diff.gz", "";
        "binutils-fix-seg-fault-in-strings-on-corrupt-pe.patch", "";
      ]
    in

    let gcc = add_full ("gcc", Some "full")
      ~dir:"slackware64-current/d"
      ~dependencies:[ gmp; mpfr; libmpc ]
      ~version:Version.gcc
      ~build:2
      ~sources:[
        Source.gcc
      ]
      ~outputs:[
        "gcc-${VERSION}-${BUILD}-${HOST_TRIPLET}.txz";
        "gcc-g++-${VERSION}-${BUILD}-${HOST_TRIPLET}.txz"
      ]
    in

    let x264 = add ("x264", None)
      ~dir:"slackbuilds.org/multimedia"
      ~dependencies:[]
      ~version:"20131101"
      ~build:1
      ~sources:[
        "${PACKAGE}-snapshot-${VERSION}-2245-stable.tar.bz2", "3c838a7979f8962bac27de5078984cf3b6e2c210";
      ]
    in

    let pcre = add ("pcre", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"8.33"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "ddfa04311c01a3882943814a3cd577080c877a8a"
      ]
    in

    let libao = add ("libao", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"1.1.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "9301bc4886f170c7122ab62677fb71cf001c04fd";
      ]
    in

    let flac = add ("flac", None)
      ~dir:"slackware64-current/ap"
      ~dependencies:[ libao (* TODO: check *) ]
      ~version:"1.3.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "38e17439d11be26207e4af0ff50973815694b26f";
      ]
    in

    let libsndfile = add ("libsndfile", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ flac; libogg; libvorbis ]
      ~version:"1.0.25"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "cfd2c6eaaed3bce1e90140cf899cf2358348944f";
      ]
    in

    let efl = efl ~variant:"regular" ~dependencies:[
      libtiff; libpng; giflib; libjpeg;
      fontconfig; freetype; lua;
      fribidi; harfbuzz; libsndfile;
      gnutls; curl; c_ares; dbus;
      (* openjpeg; current it doesn't work *)
    ]
    in

    let elementary = elementary ~variant:"regular" ~dependencies:[ efl ] in

    let gdb = add ("gdb", None)
      ~dir:"slackware64-current/d"
      ~dependencies:[]
      ~version:"7.8"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "fc43f1f2e651df1c69e7707130fd6864c2d7a428";
      ]
    in

    let libmad = add ("libmad", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"0.15.1b"
      ~build:3
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "cac19cd00e1a907f3150cc040ccc077783496d76";
        "Makefile.am", "";
        "configure.ac", "";
        "mad.pc.in", "";
      ]
    in

    let libid3tag = add ("libid3tag", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"0.15.1b"
      ~build:4
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "4d867e8a8436e73cd7762fe0e85958e35f1e4306";
      ]
    in

    let madplay = add ("madplay", None)
      ~dir:"slackware64-current/ap"
      ~dependencies:[ libid3tag; libmad ]
      ~version:"0.15.2b"
      ~build:4
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "9012438e8be93068e271df0dbeaaefae0320a1a5";
        "${PACKAGE}-${VERSION}-fix-segfault.patch.gz", "";
      ]
    in

    let lcms = add ("lcms", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ zlib; libtiff; libjpeg ]
      ~version:"1.19"
      ~build:2
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "f10eca160062562fabd4e9c7c8fb65db61da9dbf";
        "lcms1.19-avoid-buffer-overflows-CVE-2013-4276.patch", "";
      ]
    in

    let lcms2 = add ("lcms2", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"2.6"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "b0ecee5cb8391338e6c281d1c11dcae2bc22a5d2";
      ]
    in

    let djvulibre = add ("djvulibre", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"3.5.25.3"
      ~build:2
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "66e3f4f2c5db863eb5a32ff31d4b01faaa5e1916";
        "patches/0047-djvused-added-missing-command-remove-outline.patch", "";
        "patches/0053-portable-pthread_t-initialization.patch", "";
        "patches/0056-remove-extra-semi-in-test-for-std-c-includes.patch", "";
        "patches/0058-fixed-for-mingw.patch", "";
        "patches/0059-Attempt-to-work-around-typename-issues.patch", "";
        "patches/0060-more-mingw-fixes.patch", "";
        "patches/0061-removed-gstring-cruft.patch", "";
        "patches/0063-windows-recompile-reveals-issues.patch", "";
        "patches/0072-handle-period-in-crlf-files-as-well.patch", "";
        "patches/0077-fix-for-filename-conversion.patch", "";
        "patches/0079-locale-changes-for-win32.patch", "";
        "patches/0088-fixed-trivial-crash.patch", "";
        "patches/0094-meta-data-metadata.patch", "";
        "patches/0105-Fixed-small-bugs-from-Maks.patch", "";
        "patches/0107-Added-the-magic-win32-dll-option-in-LT_INIT-see-bug-.patch", "";
        "patches/0108-Cast-pointers-to-size_t-instead-of-unsigned-long.patch", "";
        "patches/0109-Added-code-to-define-inline-when-using-C.patch", "";
        "patches/0115-Fixed-clang-warnings.patch", "";
      ]
    in

    let dejavu_fonts_ttf = add ("dejavu-fonts-ttf", None)
      ~dir:"slackware64-current/x"
      ~dependencies:[]
      ~version:"2.34"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "bde72791923ac34de00e396a176307b8b71bd1a1";
      ]
    in

    let opus = add ("opus", None)
      ~dir:"slackbuilds.org/audio"
      ~dependencies:[]
      ~version:"1.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "35005f5549e2583f5770590135984dcfce6f3d58";
      ]
    in

    let a52dec = add ("a52dec", None)
      ~dir:"slackbuilds.org/audio"
      ~dependencies:[]
      ~version:"0.7.4"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "79b33bd8d89dad7436f85b9154ad35667aa37321";
      ]
    in

    let libmpeg2 = add ("libmpeg2", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"0.5.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "0f9163d8fd52db5f577ebe45636f674252641fd7";
      ]
    in

    let libsigc_plus_plus = add ("libsigc++", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"2.2.11"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "bbec3d8c54a17f19d63f9decbb91b0d79ea0d02e";
      ]
    in

    let jansson = add ("jansson", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"2.6"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "a232e0f3de4bad49b6b682f4e5df14d6c4d02676";
      ]
    in

    (* let opencore_amr = add ("opencore-amr", None)
      ~dir:"slackbuilds.org/audio"
      ~dependencies:[]
      ~version:"0.1.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz";
      ]
    in *)

    (* let faad2 = add ("faad2", None)
      ~dir:"slackbuilds.org/audio"
      ~dependencies:[]
      ~version:"2.7"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2";
      ]
    in *)

    let lame = add ("lame", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"3.99.5"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "03a0bfa85713adcc6b3383c12e2cc68a9cfbf4c4";
      ]
    in

    let qt = add ("qt", Some "regular")
      ~dir:"slackware64-current/l"
      ~dependencies:[ icu4c; zlib; sqlite; pcre; libpng; libjpeg; harfbuzz; dbus;
        (* freetype; (* build with -system-freetype is broken and probably unsupported *) *)
        (* win_iconv (* disabled by default in the build *) *)
        (* giflib (* Qt never uses the sytem one! *) *)
      ]
      ~version:"5.3.1"
      ~build:4
      ~sources:[
        "qt-everywhere-opensource-src-${VERSION}.tar.xz", "66b33ea66eb05a864e7ae417179ea24c8a45ec10";
        "0001-configure-use-pkg-config-for-libpng.patch", "";
        "0002-Use-widl-instead-of-midl.-Also-set-QMAKE_DLLTOOL-to-.patch", "";
        "0003-Tell-qmake-to-use-pkg-config.patch", "";
        "0001-QCoreApplication-ibraryPaths-discovers-plugpath-rela.patch", "";
        "Qt.pc", "";
        "qt.fix.broken.gif.crash.diff.gz", "";
        "qt.mysql.h.diff.gz", "";
        "qt.webkit-no_Werror.patch.gz", "";
        "qt5-dont-add-resource-files-to-qmake-libs.patch", "";
        "qt5-dont-build-host-libs-static.patch", "";
        "qt5-qmake-implib-dll-a.patch", "";
        "qt5-use-system-zlib-in-host-libs.patch", "";
        "qt5-workaround-qtbug-29426.patch", "";
      ]
    in

    let ffmpeg = add ("ffmpeg", None)
      ~dir:"slackbuilds.org/multimedia"
      ~dependencies:[ lame; x264; opus; libtheora; libvorbis; flac (* XXX: used? *) ]
      ~version:"2.2.10"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "384639c014d1cc747c54da311d9edadea6c482ca";
      ]
    in

    let make = add ("make", None)
      ~dir:"slackware64-current/d"
      ~dependencies:[]
      ~version:"4.0"
      ~build:5
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "b092020919f74d56118eafac2c202f25ff3b6e59";
      ]
    in

    let json_c = add ("json-c", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"0.12"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "5580aad884076c219d41160cbd8bc12213d12c37";
        "remove-unused-variable-size.patch", "";
      ]
    in

    let libgpg_error = add ("libgpg-error", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[]
      ~version:"1.13"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "50fbff11446a7b0decbf65a6e6b0eda17b5139fb";
      ]
    in

    let libgcrypt = add ("libgcrypt", None)
      ~dir:"slackware64-current/n"
      ~dependencies:[ libgpg_error ]
      ~version:"1.6.2"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "cc31aca87e4a3769cb86884a3f5982b2cc8eb7ec";
      ]
    in

    let sdl2 = add ("SDL2", None)
      ~dir:"slackbuilds.org/development"
      ~dependencies:[ win_iconv ]
      ~version:"2.0.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "21c45586a4e94d7622e371340edec5da40d06ecc";
      ]
    in

    (* This is vulnerable to CVE-2014-7901 and probably others *)
    let openjpeg = add ("openjpeg", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[ lcms; lcms2 ]
      ~version:"2.1.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "c2a255f6b51ca96dc85cd6e85c89d300018cb1cb";
      ]
    in

    let libxslt = add ("libxslt", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ libxml2 ]
      ~version:"1.1.28"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "ac0ca9da86581844ae8e77598b2d47a6d2432017";
      ]
    in

    let libdvdread = add ("libdvdread", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"5.0.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "f1fadbf19fd8d3a9a63ff610ec8ce9021ebc6947";
      ]
    in

    let libdvdnav = add ("libdvdnav", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[ libdvdread ]
      ~version:"5.0.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "9c234fc1a11f760c90cc278b702b1e41fc418b7e";
      ]
    in

    let libdvdcss = add ("libdvdcss", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"1.3.0"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "b3ccd70a510aa04d644f32b398489a3122a7e11a";
      ]
    in

    let sox = add ("sox", None)
      ~dir:"slackware64-current/ap"
      ~dependencies:[
        libao; libmad; libid3tag; lame; libvorbis; libogg; libsndfile; ffmpeg;
        (* NOTE: available: wavpack *)
        (* NOTE: available: magic *)
        (* NOTE: available: libpng ! *)
      ]
      ~version:"14.4.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "6df5d814edeb1b46354f8493507710ea95fefb2c";
      ]
    in

    let zz_config = add ("zz_config", None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"1.0.0"
      ~build:6
      ~sources:[
        "win-builds-switch.in", "";
      ]
    in

    let ocaml_findlib = add ("ocaml-findlib", None)
      ~dir:"slackbuilds.org/ocaml"
      ~dependencies:[]
      ~version:"1.5.2"
      ~build:1
      ~sources:[
        "findlib-${VERSION}.tar.gz", "4c37dabd03abe5b594785427d8f5e4adf60e6d9f";
        "findlib.conf.in", "";
      ]
    in

    let ocaml_cryptokit = add ("ocaml-cryptokit", None)
      ~dir:"slackbuilds.org/ocaml"
      ~dependencies:[ ocaml_findlib ]
      ~version:"1.9"
      ~build:1
      ~sources:[
        "cryptokit-${VERSION}.tar.gz", "2e90f27d05fe68a79747e64eef481835291babf4";
      ]
    in

    let ocaml_fileutils = add ("ocaml-fileutils", None)
      ~dir:"slackbuilds.org/ocaml"
      ~dependencies:[ ocaml_findlib ]
      ~version:"0.4.5"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "94d02385a55eef373eb96f256068d3efa724016b";
        "0001-FileUtil-replace-stat.is_link-boolean-with-a-Link-va.patch", "";
        "0002-FileUtil-symlinks-patch-2.patch", "";
      ]
    in

    let libocaml_http =
      let libocaml_add subpackage ~dependencies ~sha1 =
        add ("libocaml_" ^ subpackage, None)
          ~dir:"slackbuilds.org/ocaml"
          ~dependencies:(ocaml_findlib :: dependencies)
          ~version:"v2014-08-08"
          ~build:1
          ~sources:[ "${PACKAGE}.${VERSION}.tar.xz", sha1 ]
      in

      let exception_ = libocaml_add "exception"
        ~dependencies:[]
        ~sha1:"69c73123a46f9bc3f3b9a6ec13074d7009d8829b"
      in

      let option_ = libocaml_add "option"
        ~dependencies:[]
        ~sha1:"06401a24a9fc86a796c5ca9dd24a38c7d761cfea"
      in

      let lexing = libocaml_add "lexing"
        ~dependencies:[ exception_ ]
        ~sha1:"3d8ad03b73f423f2dc35e8fc8d77eb662b99c7e7"
      in

      let plus = libocaml_add "plus"
        ~dependencies:[ exception_ ]
        ~sha1:"ee63b54f3be5e855c4b7995dd29e384b09ce5ff6"
      in

      let ipv4_address = libocaml_add "ipv4_address"
        ~dependencies:[ exception_; option_ ]
        ~sha1:"2cf54d0e9e77b9ed61ecd2ad3c9cfe4a50c79513"
      in

      let ipv6_address = libocaml_add "ipv6_address"
        ~dependencies:[ exception_; lexing ]
        ~sha1:"12498c816ce3e10bd945f9d6dd4eff01c2400df7"
      in

      let uri = libocaml_add "uri"
        ~dependencies:[
           exception_; ipv4_address; ipv6_address; lexing; option_; plus
         ]
        ~sha1:"7335da49acfdd61f262bd41e417e422f7ee2e9c2"
      in

      libocaml_add "http"
        ~dependencies:[ lexing; option_; plus; uri ]
        ~sha1:"79a164edaa5421e987883a87a4643a86cac8c971"
    in

    let ocaml_efl = add ("ocaml-efl", None)
      ~dir:"slackbuilds.org/ocaml"
      ~dependencies:[ ocaml_findlib; elementary ]
      ~version:"1.11.1"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "c06511ef058d0676ff1873515e3b07af0e2a987a";
      ]
    in

    let _yypkg =
      let variant = "yypkg" in

      let dbus = dbus_add ~variant ~dependencies:[ expat ] in

      let harfbuzz = harfbuzz_add ~variant ~dependencies:[ freetype ] in

      let fontconfig = fontconfig_add ~variant ~dependencies:[ freetype; expat ] in

      let xz = xz_add ~variant ~dependencies:[] in

      let libarchive = libarchive_add ~variant ~dependencies:[ xz ] in

      let ocaml_archive = add ("ocaml-archive", None)
        ~dir:"slackbuilds.org/ocaml"
        ~dependencies:[ libarchive; ocaml_findlib; ocaml_fileutils ]
        ~version:"2.8.4+2"
        ~build:1
        ~sources:[
          "${PACKAGE}-${VERSION}.tar.gz", "4705e7eca920f6d831f2b8020d648d7caa18bb04";
          "0001-_oasis-make-it-possible-to-not-build-tests-docs-and-.patch", "";
          "0002-Bind-extract-set_pathname-and-read_open_memory-strin.patch", "";
          "0003-stubs-bind-archive_entry_-set_-pathname-through-a-ma.patch", "";
          "0004-Bind-archive_entry_-set_-hard-sym-link-and-archive_e.patch", "";
        ]
      in

      add ("yypkg", None)
        ~dir:"slackbuilds.org/ocaml"
        ~dependencies:[ ocaml_findlib; ocaml_cryptokit;
            ocaml_fileutils; ocaml_archive; ocaml_efl; libocaml_http;
            dbus; harfbuzz; fontconfig; libarchive
        ]
        ~version:"1.9.0"
        ~build:1
        ~sources:[
          "${PACKAGE}-${VERSION}.tar.xz", "f3d9d39037420f04c0155410b193f7d3a48ec486";
        ]
    in


    let _pdcurses = add ("PDCurses", None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"3.4"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "e36684442a6171cc3a5165c8c49c70f67db7288c";
      ]
    in

    let readline = add ("readline", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ _pdcurses ]
      ~version:"5.2"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "";
      ]
    in

    let python = add ("python", None )
      ~dir:"slackbuilds.org/python"
      ~dependencies:[ expat; libffi; bzip2; sqlite; zlib; openssl; readline ]
      ~version:"2.7.5"
      ~build:1
      ~sources:[
        "Python-2.7.5.tar.xz", "b7389791f789625c2ba9d897aa324008ff482daf";
      ]
    in

    add_full ("all", None)
      ~dir:""
      ~dependencies:[
        gcc; binutils; mingw_w64; gdb;
        elementary; gtk_2; ffmpeg;
        libtheora; opus; sox;
        madplay; icu4c; make; gperf; zz_config;
        jansson; libsigc_plus_plus;
        zlib; xz; winpthreads; pkg_config; libarchive;
        wget; dejavu_fonts_ttf;
        openjpeg; sdl2; libgcrypt;
        glib_networking; libxml2; libsoup; djvulibre; a52dec; libmpeg2;
        pcre; libxslt; libdvdread; libdvdnav; libdvdcss;
        gendef; genidl; genpeimg; widl; libmangle; winstorecompat;
        json_c;
        qt;
        check;
        bzip2;
      ]
      ~version:"0.0.0"
      ~build:1
      ~sources:[]
      ~outputs:[]

  in

  let _experimental =
    let _libidn = add ("libidn", None)
      (* NOTE: Uses gnulib with MSVC bits licensd as GPLv3; *NOT* LGPL. *)
      (* NOTE: Wget can depend on libidn (wget's license has to be checked). *)
      (* NOTE: Also, the gnulib MSVC bits don't compile; maybe an update would
       *       fix them. *)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"1.25"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "e1b18e18b0eca1852baff7ca55acce42096479da";
      ]
    in

    (* NOTE: dependency on regex *)
    (* NOTE: has an enum field "SEARCH_ALL" which conflicts with a #define from
     *       Windows and is public API. *)
    let _libcddb = add ("libcddb", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[]
      ~version:"1.3.2"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "1869ff09b522b9857f242ab4b06c5e115f46ff14";
      ]
    in

    let _wineditline = add ("wineditline", None)
      ~dir:"mingw"
      ~dependencies:[]
      ~version:"2.101"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.bz2", "7943ffde32830adff5e70aec76da78899d1e20ae";
      ]
    in

    let _libcdio = add ("libcdio", None)
      ~dir:"slackware64-current/l"
      ~dependencies:[ _libcddb ]
      ~version:"0.83"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.xz", "dc03799b2ab878def5e0517d70f65a91538e9bc1";
      ]
    in

    let _miniupnpc = add ("miniupnpc", None)
      ~dir:"slackbuilds.org/libraries"
      ~dependencies:[]
      ~version:"1.9"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "643001d52e322c52a7c9fdc8f31a7920f4619fc0";
      ]
    in

    add_full ("experimental", None)
      ~dir:""
      ~dependencies:[
      ]
      ~version:"0.0.0"
      ~build:1
      ~sources:[]
      ~outputs:[]

    (*
      let sdl:base = add ("sdl:base", None)
        ~dir:"# slackware64-current/l"
        ~dependencies:[]

      let sdl:image = add ("sdl:image", None)
        ~dir:"# slackware64-current/l"
        ~dependencies:[]

      let sdl:mixer = add ("sdl:mixer", None)
        ~dir:"# slackware64-current/l"
        ~dependencies:[]

      let sdl:net = add ("sdl:net", None)
        ~dir:"# slackware64-current/l"
        ~dependencies:[]

      let sdl:ttf = add ("sdl:ttf", None)
        ~dir:"# slackware64-current/l"
        ~dependencies:[]

      let dbus-glib = add ("dbus-glib", None)
        ~dir:"# slackware64-current/l"
        ~dependencies:[]

      let webkitgtk = add ("webkitgtk", None)
        ~dir:"# slackbuilds.org/libraries"
        ~dependencies:[]

      let gucharmap = add ("gucharmap", None)
        ~dir:"slackware64-current/xap"
        ~dependencies:[ gtk_3 ]

      (* includes <pwd.h> *)
      let geeqie = add ("geeqie", None)
        ~dir:"slackware64-current/xap"
        ~dependencies:[]

      let luajit = add ("luajit", None)
        ~dir:"slackbuilds.org/development"
        ~dependencies:[]

      let file = add ("file", None)
        ~dir:"slackware64-current/a"
        ~dependencies:[]

      let cdparanoia = add ("cdparanoia", None)
        ~dir:"slackware64-current/ap"
        ~dependencies:[ libcdio? ]

      let fdk_aac = add ("fdk-aac", None)
        ~dir:"mingw"
        ~dependencies:[]
        ~version:"2.34"
        ~build:1
        ~sources:[
          "${PACKAGE}-${VERSION}.tar.xz";
        ]
      in

    *)

  in

  let _download =
    (* fake package to reserve the name and make it known to the builder *)
    add_full ("download", None)
      ~dir:""
      ~dependencies:[]
      ~version:"0.0.0"
      ~build:1
      ~sources:[]
      ~outputs:[]
  in

  let _disabled =
    let _vpnc = add ("vpnc", None)
      ~dir:"slackbuilds.org/network"
      ~dependencies:[ (* libogg *) ]
      ~version:"0.5.3"
      ~build:1
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "321527194e937371c83b5e7c38e46fca4f109304";
      ]
    in

    let _speex = add ("speex", None)
      ~dir:"slackbuilds.org/audio"
      ~dependencies:[ (* libogg *) ]
      ~version:"1.2rc1"
      ~build:3
      ~sources:[
        "${PACKAGE}-${VERSION}.tar.gz", "52daa72572e844e5165315e208da539b2a55c5eb";
      ]
    in

    add_full ("disabled", None)
      ~dir:""
      ~dependencies:[]
      ~version:"0.0.0"
      ~build:1
      ~sources:[]
      ~outputs:[]

  in

  ()

let builder_32 =
  builder ~name:"windows_32" ~host:Config.Arch.windows_32 ~cross:Cross_toolchain.builder_32
let builder_64 =
  builder ~name:"windows_64" ~host:Config.Arch.windows_64 ~cross:Cross_toolchain.builder_64

let () =
  do_adds builder_32;
  do_adds builder_64
