#  ██╗  ██╗ ██████╗ ███╗   ███╗███████╗    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗ 
#  ██║  ██║██╔═══██╗████╗ ████║██╔════╝    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗
#  ███████║██║   ██║██╔████╔██║█████╗      ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝
#  ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝      ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗
#  ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║
#  ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
#                                                                                                              
{
  inputs,
  lib,
  config,
  pkgs,
  username,
  hostname,
  stateVersion,
  ...
}: 
let 
    # nixpkgs.url = "nixpkgs/nixos-unstable";
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  	themes = pkgs.callPackage ../common/configs/themes.nix {};
in
{
  # You can import other home-manager modules here
	imports = [ 
    ../common/configs/firefox.nix
    ../common/configs/deploy_dots.nix
    ./configs/zsh.nix 
    ./configs/hypr/default.nix 
    ../common/configs/kitty.nix 
    ../common/configs/starship.nix 
    ../common/configs/wlogout.nix
    # ../common/configs/nixvim.nix
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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      # allowUnfreePredicate = _: true;
      };
  };
	# imports = [./configs/zsh.nix ./configs/i3.nix ./configs/kitty.nix ./configs/sxhkd.nix ./configs/polybar.nix ./configs/starship.nix ]; #X Orgd
	home.username = "${username}";
	home.homeDirectory = "/home/${username}";
	home.stateVersion = stateVersion;
	programs.home-manager.enable = true;
	home.packages = with pkgs; [
#   ██████╗██╗     ██╗    ████████╗ ██████╗  ██████╗ ██╗     ███████╗
#  ██╔════╝██║     ██║    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝
#  ██║     ██║     ██║       ██║   ██║   ██║██║   ██║██║     ███████╗
#  ██║     ██║     ██║       ██║   ██║   ██║██║   ██║██║     ╚════██║
#  ╚██████╗███████╗██║       ██║   ╚██████╔╝╚██████╔╝███████╗███████║
#   ╚═════╝╚══════╝╚═╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
#                                                                    
    fira-code
    btop
    starship
    fzf
    jq
    betterdiscordctl
    sweet
    html-tidy
    nmap
    grc
    lazygit
    ydotool
    autojump
    neofetch
    fd
    bat
    rtorrent
    libnotify
    lf
    axel
    youtube-music
    playerctl
    pywal
    sass
#  ████████╗██╗  ██╗██╗   ██╗███╗   ██╗ █████╗ ██████╗ 
#  ╚══██╔══╝██║  ██║██║   ██║████╗  ██║██╔══██╗██╔══██╗
#     ██║   ███████║██║   ██║██╔██╗ ██║███████║██████╔╝
#     ██║   ██╔══██║██║   ██║██║╚██╗██║██╔══██║██╔══██╗
#     ██║   ██║  ██║╚██████╔╝██║ ╚████║██║  ██║██║  ██║
#     ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝
#                                                       
		xfce.thunar
		xfce.tumbler
#  ███████╗██╗  ██╗    ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗
#  ██╔════╝╚██╗██╔╝    ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║
#  █████╗   ╚███╔╝     █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║
#  ██╔══╝   ██╔██╗     ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║
#  ███████╗██╔╝ ██╗    ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║
#  ╚══════╝╚═╝  ╚═╝    ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
#                                                                                        
		unrar
		p7zip
    unzip
		zip
#  ███╗   ███╗███████╗██████╗ ██╗ █████╗ 
#  ████╗ ████║██╔════╝██╔══██╗██║██╔══██╗
#  ██╔████╔██║█████╗  ██║  ██║██║███████║
#  ██║╚██╔╝██║██╔══╝  ██║  ██║██║██╔══██║
#  ██║ ╚═╝ ██║███████╗██████╔╝██║██║  ██║
#  ╚═╝     ╚═╝╚══════╝╚═════╝ ╚═╝╚═╝  ╚═╝
    satty
    yt-dlp
    nerdfonts
    gimp
    ani-cli
    xwaylandvideobridge
    aria
    wf-recorder
    eww-wayland
    sxiv
    pavucontrol
    rnnoise-plugin
#   ██████╗ ██╗   ██╗██╗     █████╗ ██████╗ ██████╗ ███████╗
#  ██╔════╝ ██║   ██║██║    ██╔══██╗██╔══██╗██╔══██╗██╔════╝
#  ██║  ███╗██║   ██║██║    ███████║██████╔╝██████╔╝███████╗
#  ██║   ██║██║   ██║██║    ██╔══██║██╔═══╝ ██╔═══╝ ╚════██║
#  ╚██████╔╝╚██████╔╝██║    ██║  ██║██║     ██║     ███████║
#   ╚═════╝  ╚═════╝ ╚═╝    ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝
#                                                           
    obsidian
		discord
		zathura
		swaynotificationcenter
#  ██╗      ██████╗  ██████╗██╗  ██╗██╗███╗   ██╗ ██████╗ 
#  ██║     ██╔═══██╗██╔════╝██║ ██╔╝██║████╗  ██║██╔════╝ 
#  ██║     ██║   ██║██║     █████╔╝ ██║██╔██╗ ██║██║  ███╗
#  ██║     ██║   ██║██║     ██╔═██╗ ██║██║╚██╗██║██║   ██║
#  ███████╗╚██████╔╝╚██████╗██║  ██╗██║██║ ╚████║╚██████╔╝
#  ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 
#                                                         
        swaylock-effects
		swayidle
#   ██████╗  █████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ 
#  ██╔════╝ ██╔══██╗████╗ ████║██║████╗  ██║██╔════╝ 
#  ██║  ███╗███████║██╔████╔██║██║██╔██╗ ██║██║  ███╗
#  ██║   ██║██╔══██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║
#  ╚██████╔╝██║  ██║██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝
#   ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 
#                                                     
		lutris
		wineWowPackages.full
        yuzu-mainline
	];
  # Enable home-manager and git

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  gtk = {
	enable = true;
		# theme.package = pkgs.sweet;
		# theme.name = "Sweet-Dark";
    theme = {
      name = "Catppuccin-Mocha-Compact-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" ];
        variant = "mocha";
      };
    };

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
		eEDITOR = "nvim";    
  };

  programs.git = {
	  enable = true;
	  userName = "HirschBerge";
	  userEmail = "THIS_IS_AN_EMAIL";
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
    enableAliases = false;
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
	# programs.chromium = {
	# 	enable = true;
	# 	extensions = [
	# 		{ id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock origin
	# 		{ id = "aapbdbdomjkkjkaonfhkkikfgjllcleb";} # Google Translate
	# 		{ id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # Dark Reader
	# 		{ id = "bmnlcjabgnpnenekpadlanbbkooimhnj";} # Honey
	# 		{ id = "hdokiejnpimakedhajhdlcegeplioahd";} # Last Pass
	# 		{ id = "ponfpcnoihfmfllpaingbgckeeldkhle";} # Enhancer for Youtube
	# 		{ id = "kbfnbcaeplbcioakkpcpgfkobkghlhen";} # Grammarly
 #          { id = "amaaokahonnfjjemodnpmeenfpnnbkco";} # Grepper
	# 		{ id = "gebbhagfogifgggkldgodflihgfeippi";} # Return YouTube Dislike Button
	# 		{ id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # Sponsorblock
	# 	];
	# };
	# programs.brave = {
	# 	enable = true;
	# 	extensions = [
	# 		{ id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock origin
	# 		{ id = "aapbdbdomjkkjkaonfhkkikfgjllcleb";} # Google Translate
	# 		{ id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # Dark Reader
	# 		{ id = "bmnlcjabgnpnenekpadlanbbkooimhnj";} # Honey
	# 		{ id = "hdokiejnpimakedhajhdlcegeplioahd";} # Last Pass
	# 		{ id = "ponfpcnoihfmfllpaingbgckeeldkhle";} # Enhancer for Youtube
	# 		{ id = "kbfnbcaeplbcioakkpcpgfkobkghlhen";} # Grammarly
	# 		{ id = "gebbhagfogifgggkldgodflihgfeippi";} # Return YouTube Dislike Button
 #            { id = "amaaokahonnfjjemodnpmeenfpnnbkco";} # Grepper
	# 		{ id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # Sponsorblock
	# 	];
	# };
	services.swayidle =
    let
      lockCommand = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2";
    in
    {
      enable = true;
      systemdTarget = "hyprland-session.target";
      timeouts =
        let
          dpmsCommand = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/hyprctl dispatch dpms";
        in
        [
          {
            # timeout = 300;
            timeout = 600;
            command = lockCommand;
          }
          {
            # timeout = 600;
            timeout = 900;
            command = "${dpmsCommand} off";
            resumeCommand = "${dpmsCommand} on";
          }
        ];
      events = [
        {
          event = "before-sleep";
          command = lockCommand;
        }
        {
          event = "lock";
          command = lockCommand;
        }
        {
          event = "after-resume";
          command = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/hyprctl dispatch dpms on";
        }
      ];
    };
}

