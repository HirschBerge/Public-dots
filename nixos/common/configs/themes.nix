
{ stdenv, fetchFromGitHub }:
{
  # abstractdark-themes = stdenv.mkDerivation rec {
  #   pname = "abstractdark-themes";
  #   version = "";
  #   dontBuild = true;
  #   installPhase = ''
  #     mkdir -p $out/share/sddm/themes
  #     cp -aR $src $out/share/sddm/themes/abstractdark-themes
  #   '';
  #   src = fetchFromGitHub {
  #     owner = "3ximus";
  #     repo = "abstractdark-themes";
  #     rev = "e817d4b27981080cd3b398fe928619ffa16c52e7";
  #     sha256 = "1si141hnp4lr43q36mbl3anlx0a81r8nqlahz3n3l7zmrxb56s2y";
  #   };
  # };
  abstractguts-themes = stdenv.mkDerivation rec {
    pname = "abstractdark-themes";
    version = "";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/abstractguts-themes
    '';
    src = fetchFromGitHub {
      owner = "HirschBerge";
      repo = "abstractdark-sddm-theme";
      rev = "60284c29afebb7288ad0aea75bb93b064d9d0264";
      sha256 = "1c5azi6lvhmpbkdzc2ln33g32fh1ms0rbw2r3f0b9j81hwhl6fms";
    };
  };
  candy-icons = stdenv.mkDerivation rec {
    pname = "candy-icons";
    version = "";
    src = fetchFromGitHub {
      owner = "EliverLara";
      repo = "candy-icons";
      rev = "37b4566b4bfcdad99131a236ef1fc74db89a302e";
      sha256 = "01brz23k5y537qwxrbbyq1hcb9z7d1sgj36zg847i84gwrivcmff";
    };
    installPhase = ''
      install -dm 755 $out/share/icons
      cp -aR "$src/" "$out/share/icons/candy-icons"
    '';
  };
  fancy-dark = stdenv.mkDerivation rec { # Broken, but also just not worth ever using.
    pname = "fancy-dark-icons";
    version = "";
    src = fetchFromGitHub {
      owner = "L4ki";
      repo = "Fancy-Plasma-Themes";
      rev = "10ec357bb2ca5f7649580fb86f3f00ad447938e3";
      sha256 = "0psvrc25vj9cvn4vhkbzjmzhg2na1c5zswi4apwklna4zmn54q8k";
    };

    installPhase = ''
      install -dm 755 $out/share/icons
      cp -aR "$src/Fancy Icons Themes/Fancy-Dark-Icons" "$out/share/icons/Fancy-Dark-Icons"
    '';
  };
}
