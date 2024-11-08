{pkgs, ...}: let
  custom-font = pkgs.callPackage ./fonts-deriviation.nix {};
in {
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    font = {
      size = 12;
      name = "Dank Mono";
      package = custom-font.dank-mono;
    };
    extraConfig = ''
      symbol_map U+1F980 Noto Color Emoji
      symbol_map U+e07a Font Awesome 6 Brands Regular
      enable_audio_bell no
      background_tint 0.6
      dim_opacity 0.6
      shell zsh
      font_size 12
      map ctrl+shift+enter	launch	--cwd=current --type=os-window
      confirm_os_window_close 0
      map ctrl+shift+k clear_terminal scroll active
    '';
  };
}
