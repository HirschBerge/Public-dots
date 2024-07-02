{ pkgs, ... }:
let
  	custom-font = pkgs.callPackage ./fonts-deriviation.nix {};
in
{
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Iosevka" ]; })
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk
    noto-fonts-emoji
    fira-code
    fira-code-symbols
    custom-font.dank-mono
   # required to autoload fonts from packages installed via Home Manager
 ];
}
