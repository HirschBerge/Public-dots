{pkgs, lib, config, inputs, ... }:
{
	home.packages = with pkgs; [
		wl-clipboard
		grim
		slurp
    	swww
    	rofi-wayland
	    waybar
	];
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    # No longer exists as it is not necessary.
    # enableNvidiaPatches = true;
    xwayland.enable = true;
    extraConfig = /*bash*/ ''
########################################################################################
# AUTOGENERATED HYPR CONFIG.
# PLEASE USE THE CONFIG PROVIDED IN THE GIT REPO /examples/hypr.conf AND EDIT IT,
# OR EDIT THIS ONE ACCORDING TO THE WIKI INSTRUCTIONS.
########################################################################################
#
# Please note not all available settings / options are set here.
# For a full list, see the wiki
#
#autogenerated = 1 # remove this line to remove the warning
# See https://wiki.hyprland.org/Configuring/Monitors/
monitor = eDP-1,1920x1080@60,0x0,1
# See https://wiki.hyprland.org/Configuring/Keywords/ for more
# Execute your favorite apps at launch
# exec-once = waybar & hyprpaper & firefox
# Source a file (multi-file configs)
# source = ~/.config/hypr/myColors.conf
source = ~/.config/hypr/binds.conf
source = ~/.config/hypr/window_rules.conf
source = ~/.config/hypr/startup.conf
# Some default env vars.
env = XCURSOR_SIZE,24
# For all categories, see https://wiki.hyprland.org/Configuring/Variables/
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_rules =
    # kb_options = caps:Super_L
    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
}
general {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
    gaps_in = 5
    gaps_out = 15
    border_size = 3 
    col.active_border = rgb(711C91) rgb(EA00D9) rgb(0abdc6) 45deg
    col.inactive_border = rgb(133e7c) rgb(091833) 45deg
    layout = dwindle
}
decoration {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
    # blur_ignore_opacity = true
    rounding = 10
    fullscreen_opacity 0.69
    blur {
      enabled = true
      size = 12
      passes = 3
      new_optimizations = on
      noise = 0.05
      ignore_opacity = true
    }
    drop_shadow = yes
    shadow_range = 25
    shadow_render_power = 30
    col.shadow = rgb(711c91)
}
animations { #Thank you to HyprDots
    enabled = yes
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.1
    bezier = winOut, 0.3, -0.3, 0, 1
    bezier = liner, 1, 1, 1, 1
    animation = windows, 1, 6, wind, slide
    animation = windowsIn, 1, 6, winIn, slide
    animation = windowsOut, 1, 5, winOut, slide
    animation = windowsMove, 1, 5, wind, slide
    animation = border, 1, 1, liner
    animation = borderangle, 1, 30, liner, loop
    animation = fade, 1, 10, default
    animation = workspaces, 1, 5, wind
}
# animations {
    # enabled = yes
    # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
    # bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    # animation = windows, 1, 7, myBezier
    # animation = windowsOut, 1, 7, default, popin 80%
    # animation = border, 1, 10, default
    # animation = borderangle, 1, 8, default
    # animation = fade, 1, 7, default
    # animation = workspaces, 1, 6, default
}
dwindle {
    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    pseudotile = 0
    preserve_split = 1
    force_split = 2
}
master {
    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    new_is_master = true
}
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
}
binds {
   allow_workspace_cycles = yes
}
# Example per-device config
# See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
device:epic-mouse-v1 {
    sensitivity = -0.5
}
misc {
  # force_hypr_chan = true
  mouse_move_enables_dpms = true
}
# Enable Floating on Windows
    '';
  };
  home.file."${config.xdg.configHome}/hypr/scripts" = {
    source = ./scripts;
    recursive = true;
  };
  home.file."${config.xdg.configHome}/hypr/binds.conf".text = /* bash  */ ''
$mainMod = SUPER
# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more

bind = ALT, grave, fakefullscreen
bind = $mainMod, Return, exec, kitty
bind = $mainMod, O, killactive, 
bind = $mainMod, M, exit,
bind = $mainMod, N, exec, swaync-client -t
bind = $mainMod, R, exec,hyprctl reload
bind = $mainMod, E, exec, ~/.local/bin/dmenuunicode
bind = $mainMod, V, exec, youtube-music --disable-gpu 
bind = $mainMod, G, exec, ~/.config/hypr/scripts/gamelauncher.sh 2
# bind = $mainMod, R, exec, wofi --show drun
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle
bind = $mainMod, I, exec, ~/.scripts/scrn_record.sh
# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d
# Move Windows
bind = SUPER SHIFT, left, movewindow, l
bind = SUPER SHIFT, right, movewindow, r
bind = SUPER SHIFT, up, movewindow, u
bind = SUPER SHIFT, down, movewindow, d
# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10
# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10
# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1
# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
# Enable Floating on Windows
bind = $mainMod SHIFT, space,togglefloating
# Discord PPT 
bind = ,Insert,pass,^(.*discord*.)$

# FKey binds
bind = $mainMod, F1, exec, ~/.config/hypr/scripts/show_binds.sh
bind = $mainMod, F2, exec, ~/.local/bin/dmenumount
bind = $mainMod, F3, exec, ~/.local/bin/dmenuumount

# Other
bind = $mainMod, T, exec, thunar
bind = $mainMod, B, exec, kitty btop
bind = $mainMod, C, exec, ${pkgs.kitty}/bin/kitty ${pkgs.helix}/bin/hx ~/.dotfiles
# bind = $mainMod, U, exec, brave
bind = $mainMod, U, exec, firefox
bind = $mainMod, D, exec, ~/.config/rofi/launchers/launcher.sh
bind = ALT, space, exec, $HOME/.config/rofi/launchers/launcher.sh
bind = $mainMod, Y, exec, ~/.local/bin/yt
bind = $mainMod,F,fullscreen
bind = $mainMod,TAB,workspace,previous
bind = $mainMod SHIFT,s,exec, ~/.config/hypr/scripts/screenshot --area
bind = $mainMod, X, exec, wlogout
# bind = $mainMod,x,exec, ~/.config/rofi/powermenu/powermenu.sh
bind = $mainMod,l,exec, ~/.config/hypr/scripts/locker.sh
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 1%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 1%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
bind = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
  '';
  home.file."${config.xdg.configHome}/hypr/startup.conf".text = /* bash  */ ''
# Startup :workspace:workspace
exec = bash $HOME/.config/hypr/scripts/hypronstart.sh &
exec = bash $HOME/.config/hypr/scripts/bat_notify.sh --continue &
exec-once = swww init
exec = $HOME/.scripts/background/cron.sh ~/Pictures/Monogatari/
exec-once = /etc/profiles/per-user/hirschy/bin/firefox
exec-once = /etc/profiles/per-user/hirschy/bin/discord
# exec-once = ~/.config/hypr/scripts/sleep.sh &
exec = eww open bar &
  '';
  home.file."${config.xdg.configHome}/hypr/window_rules.conf".text = /* bash  */ ''
# Example windowrule v1
windowrule = float, ^(pavucontrol)$
windowrule = opacity 0.8 0.7, obsidian
windowrule = opacity 0.8 0.7, firefox-browser
windowrule = opacity 0.8 0.7, firefox
windowrule = opacity 0.8 0.7, thunar 
windowrulev2 = size 842 465, class:thunar
windowrulev2 = float, class:^(thunar)$
windowrulev2 = opacity 0.8 0.7, class:discord
windowrulev2 = opacity 1.0 1.0, title:^(.*YouTube.*)$
windowrulev2 = fullscreen,class:^(.*steam_app.*)$
windowrulev2 = float,class:^(.*steam_app.*)$
windowrulev2 = opacity 0.8 0.7, class:^.*kitty.*$
# windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
# See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
# App Workspace Bindings
windowrule = workspace 1, ^(.*firefox.*)$
windowrulev2 = workspace 3, class:^(.*steam_app.*)$
windowrule = workspace 8, ^(.*mpv.*)$
windowrule = workspace 7, ^(.*discord.*)$
windowrulev2 = workspace 6, class:^(.*YouTube Music.*)$# Example windowrule v2
# XwaylandVideoBridge
windowrulev2 = opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$
windowrulev2 = noanim,class:^(xwaylandvideobridge)$
windowrulev2 = nofocus,class:^(xwaylandvideobridge)$
windowrulev2 = noinitialfocus,class:^(xwaylandvideobridge)$
  '';
}
