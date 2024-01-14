{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    nodePackages_latest.bash-language-server
    kitty
    neovim
    helix
    wget
    home-manager
    traceroute
    python311
    python311Packages.pip
    ripgrep
    du-dust
    cmake
    lm_sensors
    ffmpeg
    pciutils
    # Testing out some cool rust-based replacements
    sd
    # delta #enabled by home-manager with programs.git.delta.enable = true;
    tokei
    kondo
  ];
}


