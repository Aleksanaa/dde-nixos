{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, pkg-config
, cmake
, gsettings-qt
, wrapQtAppsHook
, lshw
, dtkcommon
}:

stdenv.mkDerivation rec {
  pname = "dtkcore";
  version = "5.6.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "3c85297d3f99f1e75160db17d3689106ed882b4d";
    sha256 = "sha256-ZnuPtWb/+2/bOVsefSPpLVvUe3euxaeLWEgoTfSXiGE=";
  };

  patches = [
    (fetchpatch {
       name = "feat: optimization logic for other distribution";
       url = "https://github.com/linuxdeepin/dtkcore/commit/828f4d2c25ca77fcd80ad6100b927fb62d2edfbe.patch";
       sha256 = "sha256-mXsbzJbGOA9gAvFIK/QCFdLx/EAuotXNN4Lp3Tk4oxE";
    })
  ];

  postPatch = ''
    substituteInPlace src/dsysinfo.cpp \
      --replace "/usr/share/deepin/distribution.info" "/etc/distribution.info" \
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    gsettings-qt
    lshw
    dtkcommon
  ];

  cmakeFlags = [
    "-DBUILD_DOCS=OFF"
    "-DDSG_PREFIX_PATH='/run/current-system/sw'"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
  ];

  meta = with lib; {
    description = "Deepin tool kit core library";
    homepage = "https://github.com/linuxdeepin/dtkcore";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
