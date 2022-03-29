{ stdenv
, lib
, fetchFromGitHub
, dtkcommon
, dtkcore
, dtkgui
, dtkwidget
, qmake
, pkgconfig
, qtbase
, qttools
, qtx11extras
, wrapQtAppsHook
, qt5integration
, mtools
, p7zip
, syslinux
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-boot-maker";
  version = "5.7.6";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-UpbU1mFQGCNnf2jusa6Q5wJyMzOQLa1z0txuSqxJRH0=";
  };

  nativeBuildInputs = [ 
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook 
  ];

  buildInputs = [
    dtkcore
    dtkgui
    dtkwidget
    dtkcommon
    qtx11extras
    qt5integration
    mtools
    p7zip
    syslinux
    gtest
  ];

  qmakeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  postPatch = ''
    substituteInPlace src/src.pro \
      --replace "/usr/share/deepin-boot-maker/translations" "$out/share/deepin-boot-maker/translations"
    substituteInPlace deepin-boot-maker.pro \
      --replace "/usr/share/deepin-manual/manual-assets/application" "$out/share/deepin-manual/manual-assets/application"
  '';

  meta = with lib; {
    description = "Tool to create a bootable usb stick quick and easy";
    homepage = "https://github.com/linuxdeepin/deepin-boot-maker";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
