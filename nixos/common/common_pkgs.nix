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
    nodePackages_latest.bash-language-server
    nodePackages_latest.pyright
    black
    kitty
    neovim
    helix
    wget
    home-manager
    traceroute
    python311
    python311Packages.pip
    obs-studio
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
    mpv
    file
    pistol
    poppler_utils
    glow
  ];
}


