{
  pkgs,
  username,
  ...
}: {
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
    foot
    lm_sensors
    ffmpeg
    pciutils
    tokei
    kondo
    mpv
    sd
    file
    zellij
    zoxide
    hyprlock
    hypridle
    # bat-extras.batgrep
    bat-extras.batman
    bat-extras.batpipe
    bat-extras.batwatch
    signal-desktop
    # bat-extras.prettybat
    sshs
    atac
    termshark
    portal
    yazi
    anki
    protonmail-desktop
    rqbit
    mangal
  ];
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-anthy
      fcitx5-gtk
    ];
  };
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 5";
    flake = "/home/${username}/.dotfiles";
  };
}
