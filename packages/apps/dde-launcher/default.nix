{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, fetchpatch
, dtk
, dde-qt-dbus-factory
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, qtx11extras
, pkgconfig
, wrapQtAppsHook
, wrapGAppsHook
, gsettings-qt
, glib
, deepin-wallpapers
, gtest
, dbus
, qtbase
}:
let
  patchList = {
    ### MISC
    "dde-launcher.desktop" = [
      # "/usr/bin/dde-launcher"
    ];
    "dde-launcher-wapper" = [
      [ "dbus-send" "${dbus}/bin/dbus-send" ]
      # "/usr/share/applications/dde-launcher.desktop"
    ];

    "src/dbusservices/com.deepin.dde.Launcher.service" = [
      # "/usr/bin/dde-launcher-wapper"
    ];

    ### CODE
    "src/boxframe/backgroundmanager.cpp" = [
      [ "/usr/share/backgrounds/default_background.jpg" "${deepin-wallpapers}/share/wallpapers/deepin/desktop.jpg" ]
    ];
    "src/boxframe/boxframe.cpp" = [
      [ "/usr/share/backgrounds/default_background.jpg" "${deepin-wallpapers}/share/wallpapers/deepin/desktop.jpg" ]
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-launcher";
  version = "5.5.30";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-C6VPlfn89y5YLnkumG4iBOg9mf+GQ368B0BLp4MPPRo=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/dde-launcher/commit/121d6048092c7afc96d788e360445644e4fb95dd.diff";
      sha256 = "sha256-14hhnBWWURYuy0rbO/y2mRp6ktm6cxcZOPrVI/ruAKc=";
    })
  ];

  postPatch = getPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
    wrapGAppsHook
  ];
  dontWrapGApps = true;

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    qtx11extras
    gsettings-qt
    gtest
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Deepin desktop-environment - Launcher module";
    homepage = "https://github.com/linuxdeepin/dde-launcher";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
