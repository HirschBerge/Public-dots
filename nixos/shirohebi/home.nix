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
  email,
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
    ../common/scripts.nix
    ../common/configs/deploy_dots.nix
    ../common/configs/zsh.nix 
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
    btop
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
    eww
    unzip
    rnnoise-plugin
    sxiv
    swaynotificationcenter # dunst# mako
    wlogout
    nmap
    grc
    neofetch
    satty
    obsidian
    zathura
    xwaylandvideobridge
    sweet
    # libsForQt5.qtstyleplugin-kvantum
    aria
    ani-cli
    zip
    rtorrent
    wineWowPackages.full
    libnotify
    yt-dlp
    lf
    gimp
    p7zip
    pavucontrol
    autojump
    youtube-music
    steam
    playerctl
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
	  userEmail = "${email}";
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
    # enableAliases = false;
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
