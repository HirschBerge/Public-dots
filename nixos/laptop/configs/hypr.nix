{pkgs, lib, ... }:
{
	home.packages = with pkgs; [
		wl-clipboard
		grim
		slurp
    	swww
    	rofi-wayland
	    waybar
	];
	
}