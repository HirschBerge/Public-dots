{ pkgs, ... }:

# Created By @icanwalkonwater
# Edited and ported to Nix by Th0rgal

let
  #Monitors
  top_monitor = "DP-2";
  bottom_monitor = "DP-0";
  # Colored
  primary = "#91ddff";

  # Dark
  secondary = "#141228";

  # Colored (light)
  tertiary = "#65b2ff";

  # white
  quaternary = "#ecf0f1";

  # middle gray
  quinternary = "#20203d";

  # Red
  urgency = "#e74c3c";
  ac = "#1E88E5";
  mf = "#383838";
  bg     = "#0a0a0a";
  fg     = "#c8c8c8";
  xcolor.color1 = "#a54242";
  xcolor.color2 = "#8c9440";
  xcolor.color3 = "#de935f";
  xcolor.color4 = "#5f819d";
  xcolor.color5 = "#85678f";
  xcolor.color6 = "#5e8d87";
  xcolor.color8 = "#373b41";

  color.base-bg     = "#8c0a0a0a";
  color.glyph-bg    = "#de0a0a0a";
  color.module-bg   = "#f00a0a0a";
  color.selected-bg = "#dc1a1a1a";

  color.text-fg = "#c8c8c8";
  color.icon-fg = "#a54242";
  color.bar-fg  = "#de935f";
  color.warn-fg = "#821717";

  layout.icon-font = "2";
  layout.icon-padding = "1";
  layout.module-padding = "2";
  layout.bar-format = "%{T4}%fill%%indicator%%{F#dc404040}%empty%%{F-}%{T-}";
  layout.bar-fill-icon = "ﭳ";

in 
{
  services.polybar = {
    enable = true;

    package = pkgs.polybar.override {
      i3Support = true;
      alsaSupport = true;
      iwSupport = true;
      githubSupport = true;
    };

    script = "polybar -q -r top-primary & polybar -q -r bottom-primary & polybar -q -r top-secondary & polybar -q -r bottom-secondary &";

    config = {
      "global/wm" = {
        margin-bottom = 0;
        margin-top = 0;
      };

      #====================BARS====================#

      "bar/base" = {
        width = "100%";
        height = 28;

        background = "${color.base-bg}";
        foreground = "${color.text-fg}";

        # Size of under-/overlines
        line-size = 1;

        cursor-click = "pointer";
        cursor-scroll = "ns-resize";

        font-0 = "M+ 1m:style=Medium:size=10;3";

        # ; Material Design Icons
        font-1 = "M+ 1m:style=Medium:size=11;3";
        # ; Powerline Glyphs
        font-2 = "M+ 1m:style=Medium:size=16;3";

        # ; Larger font size for bar fill icons
        font-3 = "M+ 1m:style=Medium:size=12;3";
        # ; Smaller font size for shorter spaces
        font-4 = "M+ 1m:style=Medium:size=7;3";
        font-5 = "Noto Color Emoji:pixelsize=16:style=Regular:scale=10;2";
      };

      "bar/top-primary" = {
        "inherit" = "bar/base";
        monitor = "${top_monitor}";

        modules-left = "volume right-end-top left-end-bottom ping networkspeedup networkspeeddown right-end-top left-end-bottom playpause spotify1 right-end-top";
        modules-right = "left-end-top wifi eth public right-end-bottom left-end-top date right-end-bottom left-end-top";

        modules-center = "left-end-bottom distro-icon right-end-top left-end-bottom weather right-end-top";#"left-end-top weather right-end-top";
        tray-background = "${color.module-bg}";
        tray-padding = "${layout.module-padding}";
        tray-position = "right";
      };
      "bar/top-secondary" = {
        "inherit" = "bar/top-primary";
        monitor = "${bottom_monitor}";
        # modules-left = "volume right-end-top left-end-bottom ping networkspeedup networkspeeddown right-end-top left-end-bottom playpause spotify1 right-end-top";
        # modules-right = "left-end-top wifi eth public right-end-bottom left-end-top date right-end-bottom left-end-top";
        # modules-center = "left-end-top weather right-end-top";
        # tray-position = "none";
      };

      "bar/bottom-primary" = {
        "inherit" = "bar/base";
        monitor = "${top_monitor}";
        bottom = true;

        modules-left = "i3 right-end-bottom left-end-top title right-end-bottom";
        modules-center = "left-end-bottom nvidia right-end-bottom";
        modules-right = "left-end-bottom cpu right-end-top left-end-bottom memory right-end-top left-end-bottom temp1";
      };

      "bar/bottom-secondary" = {
        "inherit" = "bar/bottom-primary";
        monitor = "${bottom_monitor}";
      };

      "settings" = {
        throttle-output = 5;
        throttle-output-for = 10;
        throttle-input-for = 30;

        screenchange-reload = true;

        compositing-background = "source";
        compositing-foreground = "over";
        compositing-overline = "over";
        comppositing-underline = "over";
        compositing-border = "over";

        pseudo-transparency = "false";
      };



      #--------------------MODULES--------------------"

      "module/distro-icon" = {
        type = "custom/script";
        exec =
          "${pkgs.coreutils}/bin/uname -r | ${pkgs.coreutils}/bin/cut -d- -f1";
        interval = 999999999;
        click-left = "brave https://search.nixos.org/packages";
        click-right = "brave https://mipmip.github.io/home-manager-option-search/?query=";
        format = " <label>";
        format-foreground = quaternary;
        format-background = "${bg}";
        format-padding = 1;
        label = "%output%";
        label-font = 2;
      };

      "module/checknetwork" = {
        type = "custom/script";
        exec = "exec = ~/.config/polybar/scripts/check-network";
        tail = true;
        interval = 5;
        click-left = "networkmanager_dmenu &";
        click-middle = "networkmanager_dmenu &";
        click-right = "networkmanager_dmenu &";
      };

      "module/i3" = {
        "type" = "internal/i3";
        # Only show workspaces defined on the same output as the bar
        #
        # Useful if you want to show monitor specific workspaces
        # on different bars
        #
        # Default: false
        pin-workspaces = true;
        # Show urgent workspaces regardless of whether the workspace is actually hidden 
        # by pin-workspaces.
        #
        # Default: false
        # New in version 3.6.0
        show-urgent = true;
        # This will split the workspace name on ':'
        # Default: false
        strip-wsnumbers = true;
        # Sort the workspaces by index instead of the default
        # sorting that groups the workspaces by output
        # Default: false
        index-sort = true;
        # Create click handler used to focus workspace
        # Default: true
        enable-click = false;
        # Create scroll handlers used to cycle workspaces
        # Default: true
        enable-scroll = false;
        # Wrap around when reaching the first/last workspace
        # Default: true
        wrapping-scroll = false;

        # Set the scroll cycle direction 
        # Default: true
        reverse-scroll = false;

        # Use fuzzy (partial) matching on labels when assigning 
        # icons to workspaces
        # Example: code♚ will apply the icon to all workspaces 
        # containing 'code' in the label
        # Default: false

        # Active workspace on focused monitor
        label-focused = "%{T2}%icon%%{T-}  %name%";
        label-focused-background = "${color.selected-bg}";
        label-focused-underline = "${xcolor.color1}";
        label-focused-padding = "${layout.module-padding}";
        # Active workspace on unfocused monitor
        label-visible = "%{T2}%icon%%{T-}  %name%";
        label-visible-background = "${color.module-bg}";
        label-visible-underline = "${xcolor.color1}";
        label-visible-padding = "${layout.module-padding}";
        # Inactive workspace on any monitor
        label-unfocused = "%{T2}%icon%%{T-}  %name%";
        label-unfocused-background = "${color.module-bg}";
        label-unfocused-padding = "${layout.module-padding}";
        # Workspace with urgency hint set
        label-urgent = "%icon%";
        label-urgent-background = "${color.module-bg}";
        label-urgent-underline = "${color.warn-fg}";
        label-urgent-padding = "${layout.module-padding}";
        label-mode-background = "${color.module-bg}";
        label-mode-padding = "${layout.module-padding}";
     };
     "module/nvidia" = {
        type = "custom/script";
        interval = 1;
        format = "<label>";
        format-background = "${bg}";
        exec = "$HOME/.config/polybar/scripts/nvidia_mon_poly.sh";
     };
      "module/spotify1" = {
        type = "custom/script";
        interval = 1;
        format = "<label>";
        format-background = "${bg}";
        exec = "$HOME/.config/polybar/scripts/spotify_status.py  -f '{play_pause} {artist}: {song}'";
      };

      "module/ping" = {
        type = "custom/script";
        # "inherit" = "common-prefix-format";
        exec = "$HOME/.config/polybar/scripts/measure_ping.py";
        tail = true;
        format-background = bg;

        click-left = "kill -USR1 %pid%";
      };
      "module/volume" ={
        type = "internal/alsa";
        # Not muted
        format-volume = "<ramp-volume><bar-volume>";
        format-muted-background = "${bg}";
        bar-volume-background = "${bg}";
        ramp-volume-font = "${layout.icon-font}";
        ramp-volume-foreground = "${color.icon-fg}";
        ramp-volume-padding-right = "${layout.icon-padding}";
        format-volume-background = bg;
        format-connected-background = bg;


        ramp-volume-0 = "墳";

        # Bar
        bar-volume-format = "${layout.bar-format}";
        bar-volume-foreground-0 = "${color.bar-fg}";

        bar-volume-width = 6;
        bar-volume-fill = "${layout.bar-fill-icon}";
        bar-volume-indicator = "";
        bar-volume-empty = "${layout.bar-fill-icon}";
        # Muted
        format-muted-foreground = "${xcolor.color3}";
        format-muted-prefix = "婢";
        format-muted-prefix-font = "${layout.icon-font}";
        format-muted-prefix-foreground = "${color.icon-fg}";
        format-muted-prefix-padding-right = "${layout.icon-padding}";
        label-muted = "ミュート";
      };
        "module/temp1" = {
          type = "custom/script";
          interval = 1;
          format = "<label> ";
          exec = "/home/USER_NAME/.config/polybar/scripts/temp.sh";
          format-background = bg;
        };
        "module/weather" = {
          type = "custom/script";
          interval = 30;
          format = "<label> ";
          exec = "/home/USER_NAME/.proojects/Weather_app/target/debug/weather_app --polybar";
          format-background = bg;
        };
      "module/network" = {
        type = "internal/network";
        interval = 2;

        # Connected
        format-connected-prefix-font = "${layout.icon-font}";
        format-connected-prefix-foreground = "${color.icon-fg}";
        format-connected-prefix-padding-right = "${layout.icon-padding}";
        format-connected-background = bg;
        # Disconnected

        format-disconnected-foreground = "${xcolor.color3}";
        format-disconnected-background = bg;

        format-disconnected-prefix-font = "${layout.icon-font}";
        format-disconnected-prefix-foreground = "${color.icon-fg}";
        format-disconnected-prefix-padding-right = "${layout.icon-padding}";
      };
      "module/eth" ={
        "inherit" = "module/network";
        interface = "enp6s0";
        format-connected-prefix = " ";
        label-connected = "%local_ip%";
        label-disconnected = "なし ";
        # format-background = bg;
      };

      "module/wifi" = {
        "inherit" = "module/network";
        interface = "wlp5s0";
        format-connected-prefix = "直";
        label-connected = "%essid% %local_ip%";
        format-disconnected-prefix = "睊";
        label-disconnected = "なし  ";
      };
      "module/networkspeedup" ={
        type = "internal/network";
        interface = "enp6s0";
        label-connected = "%upspeed:7%";
        format-connected = "<label-connected>";
        format-connected-prefix = "↑↑";
        format-connected-prefix-foreground = "#228B22";
        format-connected-foreground = "#228B22";
        format-connected-background = bg;
      };
      "module/networkspeeddown" = {
        type = "internal/network";
        interface = "enp6s0";
        label-connected = "%downspeed:7%";
        format-connected = "<label-connected>";
        format-connected-prefix = " ↓↓";
        format-connected-prefix-foreground = "#8B0000";
        format-connected-background = bg;
        format-connected-foreground = "#8B0000";
      };
      "module/battery" = {
        type = "internal/battery";
        full-at = 101; # to disable it
        battery = "BAT0"; # TODO: Better way to fill this
        adapter = "AC0";

        poll-interval = 2;

        label-full = " 100%";
        format-full-padding = 1;
        format-full-foreground = secondary;
        format-full-background = primary;

        format-charging = " <animation-charging> <label-charging>";
        format-charging-padding = 1;
        format-charging-foreground = secondary;
        format-charging-background = primary;
        label-charging = "%percentage%% +%consumption%W";
        animation-charging-0 = "";
        animation-charging-1 = "";
        animation-charging-2 = "";
        animation-charging-3 = "";
        animation-charging-4 = "";
        animation-charging-framerate = 500;

        format-discharging = "<ramp-capacity> <label-discharging>";
        format-discharging-padding = 1;
        format-discharging-foreground = secondary;
        format-discharging-background = primary;
        label-discharging = "%percentage%% -%consumption%W";
        ramp-capacity-0 = "";
        ramp-capacity-0-foreground = urgency;
        ramp-capacity-1 = "";
        ramp-capacity-1-foreground = urgency;
        ramp-capacity-2 = "";
        ramp-capacity-3 = "";
        ramp-capacity-4 = "";
      };

      "module/cpu" = {
        type = "internal/cpu";
        interval = "0.5";
        format = "<label> <bar-load>";
        # format = "<ramp-coreload>";
        format-background = "${bg}";
        label = "%percentage:2% ％";
        format-prefix = "漣";
        bar-load-format = "${layout.bar-format}";
        bar-load-gradient = true;
        bar-load-foreground-0 = "${color.bar-fg}";
        bar-load-foreground-1 = "${color.bar-fg}";
        bar-load-foreground-2 = "${color.bar-fg}";
        bar-load-foreground-3 = "${color.warn-fg}";
        bar-load-width = 5;
        bar-load-fill = "${layout.bar-fill-icon}";
        bar-load-indicator = "";
        bar-load-empty = "${layout.bar-fill-icon}";
        # ramp-coreload-0-foreground = "#aaff77";
        # ramp-coreload-1-foreground = "#aaff77";
        # ramp-coreload-2-foreground = "#aaff77";
        # ramp-coreload-3-foreground = "#aaff77";
        # ramp-coreload-4-foreground = "#fba922";
        # ramp-coreload-5-foreground = "#fba922";
        # ramp-coreload-6-foreground = "#ff5555";
        # ramp-coreload-7-foreground = "#ff5555";
        # ramp-coreload-spacing = 1;
        # ramp-coreload-0 = "▁";
        # ramp-coreload-1 = "▂";
        # ramp-coreload-2 = "▃";
        # ramp-coreload-3 = "▄";
        # ramp-coreload-4 = "▅";
        # ramp-coreload-5 = "▆";
        # ramp-coreload-6 = "▇";
        # ramp-coreload-7 = "█";

        # format = "<label>  <ramp-coreload>";
        # label = "%percentage-cores% - %percentage%%";
        # format-prefix = "漣";

        # label = "%percentage:2% ％";

        # # Bar
        # #Spacing (number of spaces, pixels, points) between individual per-core ramps
        # "bar-load-width" = 10;
        # "bar-load-empty" = "□";
        # "bar-load-indicator" = "■";
        # "bar-load-fill" = "■";

      };

      "module/date" = {
        type = "internal/date";

        label = "%date%  %time%";

        # Date format is "MM 月 DD 日", smaller font size for spaces
        date = "%m%{T5} %{T-}%{F#404040}月%{F-}%{T5} %{T-}%d%{T5} %{T-}%{F#404040}日%{F-}";
        date-alt = "%V%{T5} %{T-}%{F#404040}週%{F-}";
        time = "%H:%M";
        time-alt = "%H:%M:%S";
        format-background = bg;
      };

      "module/title" = {
        type = "internal/xwindow";
        format = "<label>";
        # format-foreground = secondary;
        label = "%title%";
        format-background = "${bg}";
        label-maxlen = 70;
      };

      "module/memory" = {
        type = "internal/memory";
        format-prefix = "﬘ ";
        format-background = bg;
        label = "%gb_used%";
      };

      "module/temperature" = {
        type = "internal/temperature";

        interval = "0.5";

        thermal-zone = 0; # TODO: Find a better way to fill that
        warn-temperature = 60;
        units = true;

        format = "<label>";
        format-background = mf;
        format-underline = bg;
        format-overline = bg;
        format-padding = 2;
        format-margin = 0;

        format-warn = "<label-warn>";
        format-warn-background = mf;
        format-warn-underline = bg;
        format-warn-overline = bg;
        format-warn-padding = 2;
        format-warn-margin = 0;

        label = "TEMP %temperature-c%";
        label-warn = "TEMP %temperature-c%";
        label-warn-foreground = "#f00";
      };

      "module/powermenu" = {
        type = "custom/menu";
        expand-right = true;

        format = "<label-toggle> <menu>";
        format-background = secondary;
        format-padding = 1;

        label-open = "";
        label-close = "";
        label-separator = "  ";

        menu-0-0 = " Suspend";
        menu-0-0-exec = "systemctl suspend";
        menu-0-1 = " Reboot";
        menu-0-1-exec = "v";
        menu-0-2 = " Shutdown";
        menu-0-2-exec = "systemctl poweroff";
      };
      #  __
      # / _ |    _ |_  _
      # \__)|_\/|_)| |_)
      #       / |
      #
      # used as decorative dividers between modules.

      "module/glyph" = {
        type = "custom/text";
        content-font = 3;
        content-padding = 0;
        content-background = "${color.base-bg}";
        content-foreground = "${bg}";
      };
      "module/left-end-top" = {
        "inherit" = "module/glyph";
        content = "";
      };
      "module/right-end-top" = {
        "inherit" = "module/glyph";
        content = "";
        };
      "module/left-end-bottom" ={
        "inherit" = "module/glyph";
        content = "";
      };
      "module/right-end-bottom" = {
        "inherit" = "module/glyph";
        content = "";
      };
    };
  };
}
