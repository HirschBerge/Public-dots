{
  rustPlatform,
  fetchFromGitHub,
  pkgs,
  pkg-config,
  lib,
  stdenv,
  scons,
  libX11,
  libusb1,
  boost,
  glib,
  dbus-glib,
}: {
  scooter = rustPlatform.buildRustPackage rec {
    pname = "scooter";
    version = "0.1.1";

    src = fetchFromGitHub {
      owner = "thomasschafer";
      repo = "scooter";
      rev = "v${version}";
      hash = "sha256-5YosLJHfrXv6ev7r0gAW5bzkSIwIBUj/Fl3+tklTKQo=";
    };

    cargoHash = "sha256-GY52JN07igDJVuKXR9iIqNj1obhPs70dOmU1wGy8ZrI=";
  };
  talecast = rustPlatform.buildRustPackage {
    pname = "talecast";
    version = "";

    src = fetchFromGitHub {
      owner = "TBS1996";
      repo = "TaleCast";
      rev = "ebe6e7f7cd225704e30167ce0e914a50c362fd36";
      hash = "sha256-H6P/+AOnIEdfAYOcntc8agjclYrPHVVv9UDCyVKlsMQ=";
    };

    cargoHash = "sha256-f6LFMxVKXF8qhZCfXzGe6QLEyrMhsWkHG4IrqeGbNtA=";
    nativeBuildInputs = [
      pkg-config
    ];
    buildInputs = [
      pkgs.openssl
      pkgs.pkg-config
    ];
  };

  xboxdrv = stdenv.mkDerivation rec {
    pname = "xboxdrv";
    version = "0.8.8";

    src = fetchFromGitHub {
      owner = "xboxdrv";
      repo = "xboxdrv";
      rev = "v${version}";
      hash = "sha256-R0Bt4xfzQA1EmZbf7lcWLwSSUayf5Y711QhlAVhiLrY=";
    };

    makeFlags = ["PREFIX=$(out)"];
    nativeBuildInputs = [
      pkg-config
      scons
    ];
    buildInputs = [
      libX11
      libusb1
      boost
      glib
      dbus-glib
    ];
    enableParallelBuilding = true;
    dontUseSconsInstall = true;

    patches = [
      ./patches/fix-60-sec-delay.patch
      ./patches/scons-py3.patch
      ./patches/scons-v4.2.0.patch
      ./patches/xboxdrvctl-py3.patch
    ];

    meta = with lib; {
      homepage = "https://xboxdrv.gitlab.io/";
      description = "Xbox/Xbox360 (and more) gamepad driver for Linux that works in userspace";
      license = licenses.gpl3Plus;
      maintainers = [];
      platforms = platforms.linux;
    };
  };
}
