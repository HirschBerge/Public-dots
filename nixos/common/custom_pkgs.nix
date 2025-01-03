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
}
