{ stdenv, fetchFromGitHub, pkgs, ... }:

{
    dank-mono = stdenv.mkDerivation rec {
    pname = "dank_mono";
    version = "";
    dontBuild = true;
    nativeBuildInputs = [ pkgs.unzip ];
    buildInputs = [ pkgs.unzip ];
    installPhase = ''
      mkdir -p $out/share/fonts/
      unzip $src/DankMono.zip -d $out/share/fonts
    '';
    src = fetchFromGitHub {
      owner = "redacted";
      repo = "fonts";
      rev = "REV";
      sha256 = "sha";
    };
  };
}
