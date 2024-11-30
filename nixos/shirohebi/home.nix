#  ██╗  ██╗ ██████╗ ███╗   ███╗███████╗    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗
#  ██║  ██║██╔═══██╗████╗ ████║██╔════╝    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗
#  ███████║██║   ██║██╔████╔██║█████╗      ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝
#  ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝      ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗
#  ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║
#  ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
#
{
  email,
  pkgs,
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
    # You can add overlays here
    #   overlays = [
    #
    #   ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    btop
    brightnessctl
    fzf
    bat
    axel
    jq
    fd
    lazygit
    xfce.thunar
    xfce.tumbler
    eww
    # swaynotificationcenter # dunst# mako
    wlogout
    nmap
    grc
    satty
    # libsForQt5.qtstyleplugin-kvantum
    aria
    # ani-cli NOTE: uncomment when new version is released
    rtorrent
    libnotify
    yt-dlp
    gimp
    pavucontrol
    steam
    playerctl
    wf-recorder
  ];
  programs.lf = {
    enable = true;
  };
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
      name = "Catppuccin-Mocha-Mauve-Cursors";
    };
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=Sweet-Dark
  '';
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
  home.sessionVariables = {
    GTK_USE_PORTAL = 1;
    eEDITOR = "nvim";
  };

  programs.git = {
    enable = true;
    userName = "HirschBerge";
    userEmail = "${email}";
    extraConfig = {
      init.defaultBranch = "main";
    };
    signing = {
      signByDefault = true;
      key = null;
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
  programs.eza = {
    enable = true;
    # enableAliases = false;
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
    # HACK: Patches the Dank Mono font to be usable with Kitty
    "fontconfig/conf.d/75-disable-fantasque-calt.conf".text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
      <match target="scan">
      <test name="family">
      <string>Dank Mono</string>
      <!-- <string>Dank Mono Italic</string> -->
      </test>
      <edit name="spacing">
      <int>100</int>
      </edit>
      </match>
      </fontconfig>
    '';
  };
}
