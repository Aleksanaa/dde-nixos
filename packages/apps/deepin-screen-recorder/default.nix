{ stdenv
, lib
, fetchpatch
, fetchFromGitHub
, getUsrPatchFrom
, replaceAll
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, dde-dock
, image-editor
, gsettings-qt
, cmake
, qmake
, qttools
, pkg-config
, qtmultimedia
, qtx11extras
, wrapQtAppsHook
, xorg
, gst_all_1
, libusb1
, ffmpeg
, ffmpegthumbnailer
, portaudio
, libv4l
, udev
, kwayland
, dbus
, qtbase
, patchelf
, glib
}:
let
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with gst_all_1; [ gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad ]);
  patchList = {
    "screen_shot_recorder.pro " = [ ];
    "src/src.pro" = [ ];
    "src/pin_screenshots/pin_screenshots.pro" = [ ];
    "src/dde-dock-plugins/shotstart/shotstart.pro" = [ ];
    "src/dde-dock-plugins/recordtime/recordtime.pro" = [ ];

    ###MISC
    "deepin-screen-recorder.desktop" = [ ];
    "assets/screenRecorder.json" = [
      # /usr/share/deepin-screen-recorder/tablet_resources/fast-icon_recording_normal.svg
    ];
    "com.deepin.Screenshot.service" = [  ];
    "src/dbusservice/com.deepin.Screenshot.service" = [
      [ "/usr/bin/deepin-turbo-invoker" "deepin-turbo-invoker" ]
      # /usr/bin/deepin-screenshot
    ];
    "src/pin_screenshots/com.deepin.PinScreenShots.service" = [ ];
    "assets/com.deepin.Screenshot.service" = [ ];
    "assets/com.deepin.ScreenRecorder.service" = [ ];
    
    "src/recordertablet.cpp" = [
      # "/usr/share/deepin-screen-recorder/tablet_resources" 
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "deepin-screen-recorder";
  version = "5.11.15";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-X9eqi6zDtWOc0J8zIwR1y6EWhTG09vEVViLVwRPuAGo=";
  };

  patches = [
    (fetchpatch {
      name = "fix: don't hardcode /usr/bin path";
      url = "https://github.com/linuxdeepin/deepin-screen-recorder/commit/ba5b80521b729946a907dc6c285bb8ca4b6dd8b3.patch";
      sha256 = "sha256-MTRozOJo1HUBpi6HZRaXPl/XKyr/dSyRC0xRucaCapY";
    })
  ];

  postPatch = getUsrPatchFrom patchList + replaceAll "/usr/bin/dbus-send" "${dbus}/bin/dbus-send";

  qmakeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  nativeBuildInputs = [
    qmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    dde-dock
    image-editor
    gsettings-qt
    qtmultimedia
    qtx11extras
    xorg.libXdmcp
    xorg.libXtst
    xorg.libXcursor.dev
    gst_all_1.gst-plugins-base.dev
    kwayland
    libusb1
    libv4l
    ffmpeg.dev
    ffmpegthumbnailer
    portaudio
    udev
  ] ++ ( with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ]);

  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ ffmpeg ]}"
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gstPluginPath}"
  ];

  preFixup = ''
      patchelf --add-needed ${udev}/lib/libudev.so $out/bin/deepin-screen-recorder
      patchelf --add-needed ${libv4l}/lib/libv4l2.so $out/bin/deepin-screen-recorder
      glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
  '';

  meta = with lib; {
    description = "screen recorder application for dde";
    homepage = "https://github.com/linuxdeepin/deepin-screen-recorder";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
