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
    ./configs/zsh.nix 
    ./configs/hypr.nix 
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
		btop
        noto-fonts-color-emoji
        jetbrains-mono
        fira-code
        brightnessctl
		starship
		fzf
		bat
		axel
        jq
        fd
        lazygit
		xfce.thunar
		xfce.tumbler
		nerdfonts
		eww-wayland
		unzip
        rnnoise-plugin
		sxiv
        swaynotificationcenter# dunst# mako
        swaylock-effects
        swayidle
        wlogout
		betterdiscordctl
		nmap
		grc
		neofetch
        satty
		mangohud
		obsidian
		zathura
        xwaylandvideobridge
		sweet
		# libsForQt5.qtstyleplugin-kvantum
        aria
		ani-cli
	    zip
	    rtorrent
	    lutris
	    wineWowPackages.full
	    libnotify
        yt-dlp
	    ranger
	    gimp
	    p7zip
	    pavucontrol
	    autojump
	    youtube-music
	    steam
	    mpv
	    playerctl
	    discord
        pywal
	    wf-recorder
	];
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
		# iconTheme = {
		# 	package = pkgs.catppuccin-papirus-folders.override {
		# 	  	flavor = "mocha";
		# 	   	accent = "mauve";
		# 	};
		# 	name = "Papirus-Dark";
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
    # QT_STYLE_OVERRIDE = "kvantum";
    GTK_USE_PORTAL = 1;
		eEDITOR = "nvim";    
  };

	programs.git = {
		enable = true;
		userName = "HirschBerge";
		userEmail = "THIS_IS_AN_EMAIL";
	};
	programs.fzf = {
		enable = true;
		enableZshIntegration = true;
	};
  programs.eza = {
    enable = true;
    enableAliases = true;
    git = true;
    icons = true;
    extraOptions = [
    "--group-directories-first"
    "--header"
    "-o"
    "--no-permissions"
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
	# 		{ id = "gebbhagfogifgggkldgodflihgfeippi";} # Return YouTube Dislike Button
 #            { id = "amaaokahonnfjjemodnpmeenfpnnbkco";} # Grepper
 #            { id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # Sponsorblock
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
 #            { id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # Sponsorblock
	# 	];
	# };
	
}

