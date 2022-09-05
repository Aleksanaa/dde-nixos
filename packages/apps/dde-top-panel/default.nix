{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, gsettings-qt
, qt5integration
, udisks2-qt5
, cmake
, qttools
, qtx11extras
, kwindowsystem
, pkgconfig
, dde-qt-dbus-factory
, wrapQtAppsHook
, xorg
, xdotool
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "dde-top-panel";
  version = "unstable-2022-08-30";

  src = fetchFromGitHub {
    owner = "SeptemberHX";
    repo = pname;
    rev = "5d51ae46bce1bd3d2cf175879eac06426ece94b9";
    sha256 = "sha256-/Oi+t/rFW+1D+++0ChOMBW9zTOec8RLZMMIJnC15DU0=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    gsettings-qt
    qtx11extras
    kwindowsystem
    dde-qt-dbus-factory
    xorg.libXdmcp
    xdotool
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
  ];

#   fixPluginLoadPatch = ''
#     substituteInPlace src/source/common/pluginmanager.cpp \
#       --replace "/usr/lib/" "$out/lib/"
#   '';

#  postPatch = fixPluginLoadPatch;

  meta = with lib; {
    description = "Top panel for deepin desktop environment v20";
    homepage = "https://github.com/SeptemberHX/dde-top-panel";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}