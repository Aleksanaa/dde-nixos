{ stdenv
, lib
, fetchFromGitHub
, qmake
, qttools
, pkg-config
, wrapQtAppsHook
, dtkwidget
, qtbase
, qtsvg
, xorg
}:

stdenv.mkDerivation rec {
  pname = "deepin-picker";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-DkSgeMALhwGeU5sDHuerpPpiN3/3m19jmwtwOjZvOVo=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    dtkwidget
    qtsvg
    xorg.libXtst
  ];

  postPatch = ''
    substituteInPlace com.deepin.Picker.service \
      --replace "/usr/bin/deepin-picker" "$out/bin/deepin-picker"
  '';

  qmakeFlags = [
    "BINDIR=${placeholder "out"}/bin"
    "ICONDIR=${placeholder "out"}/share/icons/hicolor/scalable/apps"
    "APPDIR=${placeholder "out"}/share/applications"
    "DSRDIR=${placeholder "out"}/share/deepin-picker"
    "DOCDIR=${placeholder "out"}/share/dman/deepin-picker"
  ];

  meta = with lib; {
    description = "Color picker application";
    homepage = "https://github.com/linuxdeepin/deepin-picker";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}