{ pkgs, ...}:
{
    nixpkgs.overlays = [
    (self: super: {
      mpv = super.mpv.override {
        scripts = [ self.mpvScripts.mpris self.mpvScripts.sponsorblock self.mpvScripts.thumbfast];
      };
    })
  ];
  environment.systemPackages = with pkgs; [
    # Neovim Deps
    nodejs_21
    clipse
    lua-language-server
    kitty
    neovim
    helix
    wget
    home-manager
    traceroute
    python312
    python312Packages.pip
    python312Packages.tkinter
    python312Packages.numpy
    obs-studio
    ripgrep
    du-dust
    cmake
    lm_sensors
    ffmpeg
    pciutils
    # Testing out some cool rust-based replacements
    sd # Sed replacement
    # delta #enabled by home-manager with programs.git.delta.enable = true;
    tokei
    kondo
    mpv
    file
    pistol
    poppler_utils
    zellij
    zoxide
    pika-backup
    hyprlock
    hypridle
    warp-terminal
  ];
}


