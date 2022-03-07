{ pkgs ? import <nixpkgs> {} }:
let 
  makeScope = pkgs.lib.makeScope;

  libsForQt5 = pkgs.libsForQt5;
  
  packages = self: with self; {
    deepin-desktop-base = callPackage ./pkgs/deepin-desktop-base { };
    dde-qt-dbus-factory = callPackage ./pkgs/dde-qt-dbus-factory { };
    dtkcommon = callPackage ./pkgs/dtkcommon { };
    dtkcore = callPackage ./pkgs/dtkcore { };
    dtkgui = callPackage ./pkgs/dtkgui { };
  };
in
makeScope libsForQt5.newScope packages
