{config, pkgs, ...}:
{
	services.sxhkd = {
		enable = true;
		keybindings = {
			"super + y" = "/home/USER_NAME/.local/bin/yt";
			"super + Return" = "kitty";
			"super + shift + s" = "maim -s | xclip -selection clipboard -t image/png";
			"super + shift + q" = "kill -9 `xdotool getwindowfocus getwindowpid`";
			"super + d" = "~/.config/rofi/launchers/type-7/launcher.sh";
			"super + e" = "echo open";
			"super + w" = "echo open";
			"super + shift + w" = "chromium https://roll20.net https://pathbuilder2e.com https://drive.google.com";
			"super + l" = "i3lock-fancy-rapid 5 3";
			"super + x" = "~/.config/rofi/powermenu/type-5/powermenu.sh";
			"shift + Print" = "~/.local/bin/maimpick";
			"super + shift + F1" = "echo open";
			"super + F2" = "i3 restart";
			"super + F3" = "displayselect";
			"super + F4" = "prompt 'Hibernate computer?' 'sudo -A zzz -Z'";
			"super + F5 is unbound" = "";
			"super + {F9,F10}" = "{dmenumount,dmenuumount}";
			# "super + o" = "kill $(xdotool getwindowfocus getwindowpid)";
		};
	};
}