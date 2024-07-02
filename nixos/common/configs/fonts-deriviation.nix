{ lib, stdenv, fetchFromGitHub, pkgs, ... }:

{
    dank-mono = stdenv.mkDerivation rec {
    pname = "dank_mono";
    version = "";
    dontBuild = true;
    dontConfigure = true;
    nativeBuildInputs = [ pkgs.unzip ];
    buildInputs = [ pkgs.unzip ];
 
    installPhase = ''
      mkdir -p $out/share/fonts/
      ${pkgs.unzip}/bin/unzip $src/DankMono.zip -d $out/share/fonts
    '';
 
  meta = with lib; {
    description = ''
      A typeface designed for coding aesthetes with modern displays in mind.
      Delightful ligatures and an italic variant and bold style.
    '';
    homepage = "https://philpl.gumroad.com/l/dank-mono";
    license = licenses.unfree;
  };
    src = fetchFromGitHub {
      owner = "cancng";
      repo = "fonts";
      rev = "f130dce1bd8ed572747861c315d43635780cbb98";
      sha256 = "180d5pk3dbaahv5fry0wmgz6fwnly8jqpl4anhnpla2f44qql71q";
    };
  };
}
