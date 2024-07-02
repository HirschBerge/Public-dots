{ pkgs,
  username,
 ...}:
{
  environment.systemPackages = with pkgs; [
    tlrc
    clipse
    zig
    lua-language-server
    kitty
    vesktop
    neovim
    helix
    wget
    home-manager
    traceroute
    python312
    obs-studio
    ripgrep
    du-dust
    cmake
    lm_sensors
    ffmpeg
    pciutils
    tokei
    kondo
    mpv
    sd
    file
    pistol
    poppler_utils
    zellij
    zoxide
    pika-backup
    hyprlock
    hypridle
    # bat-extras.batgrep
    # bat-extras.batman
    bat-extras.batpipe
    bat-extras.batwatch
    # bat-extras.prettybat
  ];
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 5";
    flake = "/home/${username}/.dotfiles";
  };
  programs.thefuck = {
    enable = true;
    alias = "tf";
  };
}


