#  ██╗  ██╗ ██████╗ ███╗   ███╗███████╗    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗
#  ██║  ██║██╔═══██╗████╗ ████║██╔════╝    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗
#  ███████║██║   ██║██╔████╔██║█████╗      ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝
#  ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝      ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗
#  ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║
#  ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
#
{
  pkgs,
  email,
  username,
  stateVersion,
  inputs,
  ...
}: let
  themes = pkgs.callPackage ../common/configs/themes.nix {};
in {
  # You can import other home-manager modules here
  imports = [
    ../common/configs/default.nix
    ../common/scripts.nix
    ./configs/hypr/default.nix
  ];
  nixpkgs = {
    # NOTE: You can add overlays here
    #   overlays = [
    #   ];

    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      # allowUnfreePredicate = _: true;
    };
  };
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    btop
    fzf
    jq
    nmap
    grc
    lazygit
    ydotool
    fd
    bat
    rtorrent
    libnotify
    axel
    youtube-music
    playerctl
    xfce.thunar
    xfce.tumbler
    satty
    yt-dlp
    gimp
    # ani-cli NOTE: uncomment when new version is released
    aria
    wf-recorder
    eww
    pavucontrol
    obsidian
    # swaynotificationcenter
    wineWowPackages.full
    appimage-run
  ];
  # Enable home-manager and git
  programs.lf = {
    enable = true;
  };
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "catppuccin-mocha-mauve";
    };
  };
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  gtk = {
    enable = true;
    theme = {
      package = pkgs.sweet;
      name = "Sweet-Dark";
    };
    # NOTE: Also a nice theme
    # theme = {
    #   name = "Nightfox-Dusk-B";
    #   package = pkgs.nightfox-gtk-theme;
    # };

    iconTheme = {
      name = "candy-icons";
      package = themes.candy-icons;
    };
    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaMauve;
      name = "catppuccin-mocha-mauve";
      size = 24;
    };
    font = {
      name = "TerminaTest-Demi";
      size = 12;
    };
  };
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=Sweet-Dark
  '';
  home.sessionVariables = {
    # QT_STYLE_OVERRIDE = "kvantum";
    GTK_USE_PORTAL = 1;
    eEDITOR = "v";
    ATAC_KEY_BINDINGS = "~/.config/keybindings.toml";
    ZELLIJ_AUTO_EXIT = "TRUE";
  };

  programs.git = {
    enable = true;
    userName = "HirschBerge";
    userEmail = "${email}";
    signing = {
      signByDefault = true;
      key = "13167AC5444C6810";
    };
    extraConfig = {
      init.defaultBranch = "main";
    };
    delta = {
      enable = true;
      options = {
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow ul";
        };
        features = "decorations";
        line-numbers = true;
        side-by-side = true;
        whitespace-error-style = "22 reverse";
      };
    };
  };
  programs.wezterm = {
    enable = true;
    package = inputs.wezterm.packages.${pkgs.system}.default;
    extraConfig =
      /*
      lua
      */
      ''
        local Config = require('config')

        require('utils.backdrops')
           :set_files()
           -- :set_focus('#000000')
           :random()

        require('events.right-status').setup()
        require('events.left-status').setup()
        require('events.tab-title').setup()
        require('events.new-tab-button').setup()

        return Config:init()
           :append(require('config.appearance'))
           :append(require('config.bindings'))
           :append(require('config.domains'))
           :append(require('config.fonts'))
           :append(require('config.general'))
           :append(require('config.launch')).options
      '';
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.thefuck = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
  };
  programs.eza = {
    enable = true;
    git = true;
    icons = "always";
    extraOptions = [
      "--group-directories-first"
      "--header"
      "-o"
      "--no-permissions"
      "--hyperlink"
    ];
  };
  fonts.fontconfig.enable = true;

  xdg.configFile = {
    # HACK: Patches Dank Mono to work for kitty
    "fontconfig/conf.d/75-disable-fantasque-calt.conf".text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
          <!-- Dank Mono configuration -->
          <match target="scan">
              <test name="family">
                  <string>Dank Mono</string>
                  <!-- <string>Dank Mono Italic</string> -->
              </test>
              <edit name="spacing">
                  <int>100</int>
              </edit>
          </match>

          <!-- Font Awesome 6 Free-Regular-400 configuration -->
          <match target="scan">
              <test name="family">
                  <string>Font Awesome 6 Free</string>
              </test>
              <edit name="spacing">
                  <int>100</int>
              </edit>
          </match>

          <!-- Font Awesome 6 Brands-Regular-400 configuration -->
          <match target="scan">
              <test name="family">
                  <string>Font Awesome 6 Brands</string>
              </test>
              <edit name="spacing">
                  <int>100</int>
              </edit>
          </match>

          <!-- Font Awesome 6 Free-Solid-900 configuration -->
          <match target="scan">
              <test name="family">
                  <string>Font Awesome 6 Free</string>
              </test>
              <edit name="spacing">
                  <int>100</int>
              </edit>
          </match>
      </fontconfig>
    '';
  };

  programs.yt-dlp = {
    enable = true;
    extraConfig =
      /*
      bash
      */
      ''

        # Always remove all sponsor segments
        --sponsorblock-remove all
        --continue
        --fixup=detect_or_warn
        --embed-metadata
        --embed-thumbnail
        --embed-chapters
        --output "%(title)s.%(ext)s"
        --merge-output-format mp4
        # Always download at 1440p resolution
        --format "bestvideo[height<=1440]+bestaudio/best[height<=1440]"
      '';
  };
}
#

