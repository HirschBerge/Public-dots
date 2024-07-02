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
    ...
}: 
let 
themes = pkgs.callPackage ../common/configs/themes.nix {};
in
{
# You can import other home-manager modules here
  imports = [ 
    ../common/scripts.nix
    ../common/configs/firefox.nix
    ../common/configs/zathura.nix
    ../common/configs/zellij.nix
    ../common/configs/rofi.nix
    ../common/configs/mpv.nix
    ../common/configs/deploy_dots.nix
    ../common/configs/zsh.nix 
    ./configs/hypr/default.nix 
    ../common/configs/kitty.nix 
    ../common/configs/starship.nix 
    ../common/configs/wlogout.nix
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
      autojump
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
      ani-cli
      aria
      wf-recorder
      eww
      pavucontrol
      obsidian
      swaynotificationcenter
      wineWowPackages.full
      appimage-run
      ];
# Enable home-manager and git
  programs.lf = {
    enable = true;
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
      name = "Catppuccin-Mocha-Mauve-Cursors";
      size = 40;
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
  };

  programs.git = {
    enable = true;
    userName = "HirschBerge";
    userEmail = "${email}";
    signing = {
      signByDefault = true;
      key = null;
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
	whitespace-error-style = "22 reverse";
      };
    };
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.eza = {
    enable = true;
    git = true;
    icons = true;
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
#
