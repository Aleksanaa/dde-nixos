{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, dtkgui
, dtkwidget
, dtkcommon
, cmake
, qttools
, pkgconfig
, wrapQtAppsHook
, fontconfig
, freetype
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-font-manager";
  version = "5.9.6";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-C5Wj4s5JG9k2BKMKEMS6WO2bYU6G7xwWYk4lxUzjkHA=";
  };

  nativeBuildInputs = [ 
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook 
  ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    fontconfig
    freetype
    gtest
  ];

  #TODO: deepin-font-preview-plugin need dde-file-manger
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "ADD_SUBDIRECTORY(deepin-font-preview-plugin)" " " \
      --replace "/usr/share/deepin-manual/manual-assets/application/)" "$out/share/deepin-manual/manual-assets/application/)" \
      --replace "SET(CMAKE_INSTALL_PREFIX /usr)" "SET(CMAKE_INSTALL_PREFIX $out)"
  '';

  meta = with lib; {
    description = "Deepin Font Manager is used to install and uninstall font file for users with bulk install function";
    homepage = "https://github.com/linuxdeepin/deepin-font-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
