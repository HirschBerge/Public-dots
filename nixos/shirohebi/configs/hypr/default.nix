{
  pkgs,
  config,
  ...
}: let
  term = "${pkgs.kitty}/bin/kitty";
in {
  home.packages = with pkgs; [
    wl-clipboard
    waypaper
    grim
    slurp
    swww
    hyprland
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland; # TODO: Comment back in when hyprland is stable again
    xwayland.enable = true;
    extraConfig =
      /*
      hyprlang
      */
      ''
        source = ~/.config/hypr/binds.conf
        source = ~/.config/hypr/window_rules.conf
        source = ~/.config/hypr/startup.conf
        # Some default env vars.
        env = HYPRCURSOR_THEME,catppuccin-mocha-mauve
        env = HYPRCURSOR_SIZE,35
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
            # fullscreen_opacity =  0.69
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
        dwindle {
            # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
            pseudotile = 0
            preserve_split = 1
            force_split = 2
        }
        master {
            # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
            new_status = master
        }
        gestures {
            workspace_swipe = true
            workspace_swipe_fingers = 3
        }
        binds {
           allow_workspace_cycles = yes
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
  home.file."${config.xdg.configHome}/hypr/binds.conf".text =
    /*
    hyprlang
    */
    ''
      monitor = eDP-1,1920x1080@60,0x0,1
      $mainMod = SUPER
      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more

      bindd = ALT, grave, Toggles fullscreen state, fullscreenstate, 0 2
      bindd = $mainMod, Return, Opens terminal, exec, ${term}
      bindd = $mainMod, O, Closes active window, killactive,
      bindd = $mainMod, M, Exits the window manager, exit,
      bindd = $mainMod, N, Launches dashboard, exec, bash -c ~/.config/eww/scripts/launch_dashboard
      bindd = $mainMod, R, Reloads Hyprland configuration, exec, hyprctl reload
      bindd = $mainMod, E, Opens dmenuunicode, exec, ~/.nix-profile/bin/dmenuunicode
      bindd = $mainMod, S, Searches Nix packages, exec, ~/.config/eww/scripts/search_nixpkgs.sh
      bindd = $mainMod, V, Opens Clipse in Kitty for clipboard, exec, ${pkgs.kitty}/bin/kitty --title clipse -e zsh -c '${pkgs.clipse}/bin/clipse $PPID'
      bindd = $mainMod, G, Runs game launcher script, exec, ~/.config/hypr/scripts/gamelauncher.sh 2
      bindd = $mainMod, P, Toggles pseudo mode (dwindle), pseudo,
      bindd = $mainMod, J, Toggles split mode (dwindle), togglesplit,
      bindd = $mainMod, I, Starts screen recording, exec, ~/.scripts/scrn_record.sh

      # Move focus with mainMod + arrow keys
      bindd = $mainMod, left, Moves focus left, movefocus, l
      bindd = $mainMod, right, Moves focus right, movefocus, r
      bindd = $mainMod, up, Moves focus up, movefocus, u
      bindd = $mainMod, down, Moves focus down, movefocus, d

      # Move Windows
      bindd = SUPER SHIFT, left, Moves window left, movewindow, l
      bindd = SUPER SHIFT, right, Moves window right, movewindow, r
      bindd = SUPER SHIFT, up, Moves window up, movewindow, u
      bindd = SUPER SHIFT, down, Moves window down, movewindow, d

      # Switch workspaces with mainMod + [0-9]
      bindd = $mainMod, 1, Switches to workspace 1, workspace, 1
      bindd = $mainMod, 2, Switches to workspace 2, workspace, 2
      bindd = $mainMod, 3, Switches to workspace 3, workspace, 3
      bindd = $mainMod, 4, Switches to workspace 4, workspace, 4
      bindd = $mainMod, 5, Switches to workspace 5, workspace, 5
      bindd = $mainMod, 6, Switches to workspace 6, workspace, 6
      bindd = $mainMod, 7, Switches to workspace 7, workspace, 7
      bindd = $mainMod, 8, Switches to workspace 8, workspace, 8
      bindd = $mainMod, 9, Switches to workspace 9, workspace, 9
      bindd = $mainMod, 0, Switches to workspace 10, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bindd = $mainMod SHIFT, 1, Moves active window to workspace 1, movetoworkspace, 1
      bindd = $mainMod SHIFT, 2, Moves active window to workspace 2, movetoworkspace, 2
      bindd = $mainMod SHIFT, 3, Moves active window to workspace 3, movetoworkspace, 3
      bindd = $mainMod SHIFT, 4, Moves active window to workspace 4, movetoworkspace, 4
      bindd = $mainMod SHIFT, 5, Moves active window to workspace 5, movetoworkspace, 5
      bindd = $mainMod SHIFT, 6, Moves active window to workspace 6, movetoworkspace, 6
      bindd = $mainMod SHIFT, 7, Moves active window to workspace 7, movetoworkspace, 7
      bindd = $mainMod SHIFT, 8, Moves active window to workspace 8, movetoworkspace, 8
      bindd = $mainMod SHIFT, 9, Moves active window to workspace 9, movetoworkspace, 9
      bindd = $mainMod SHIFT, 0, Moves active window to workspace 10, movetoworkspace, 10

      # Scroll through existing workspaces with mainMod + scroll
      bindd = $mainMod, mouse_down, Scrolls to next workspace, workspace, e+1
      bindd = $mainMod, mouse_up, Scrolls to previous workspace, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # Enable Floating on Windows
      bindd = $mainMod SHIFT, space, Toggles floating mode, togglefloating

      # Discord PPT
      bindd = , Insert, Passes through to Discord, pass, ^(.*discord*.)$

      # FKey binds
      bindd = $mainMod, F1, Shows keybinds script, exec, ~/.config/hypr/scripts/show_binds.sh
      bindd = $mainMod, F2, Mounts drives via dmenumount, exec, ~/.local/bin/dmenumount
      bindd = $mainMod, F3, Unmounts drives via dmenuumount, exec, ~/.local/bin/dmenuumount

      # Other
      bindd = $mainMod, T, Opens Thunar file manager, exec, thunar
      bindd = $mainMod, B, Opens Btop in Kitty, exec, kitty btop
      bindd = $mainMod, C, Opens Helix editor in Kitty, exec, ${pkgs.kitty}/bin/kitty ${pkgs.helix}/bin/hx ~/.dotfiles
      bindd = $mainMod, U, Launches Firefox, exec, firefox
      bindd = $mainMod, D, Opens Rofi launcher, exec, rofi -show drun window calc emoji
      bindd = ALT, space, Opens Rofi launcher, exec, rofi -show drun window calc emoji
      bindd = $mainMod, Y, Runs YouTube script, exec, yt
      bindd = , XF86Calculator, Opens Rofi calculator, exec, rofi -show calc
      bindd = $mainMod, F, Toggles fullscreen, fullscreen
      bindd = $mainMod, TAB, Switches to previous workspace, workspace, previous
      bindd = $mainMod SHIFT, S, Takes an area screenshot, exec, ~/.config/hypr/scripts/screenshot --area
      bindd = $mainMod SHIFT, W, Takes a window screenshot, exec, ~/.config/hypr/scripts/screenshot --win
      bindd = $mainMod SHIFT, A, Launches Waypaper wallpaper manager, exec, ${pkgs.waypaper}/bin/waypaper
      bindd = $mainMod, X, Launches wlogout, exec, wlogout
      bindd = $mainMod, l, Locks screen with Hyprlock, exec, ${pkgs.hyprlock}/bin/hyprlock
      bindd = , XF86AudioRaiseVolume, Increases volume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 1%+
      bindd = , XF86AudioLowerVolume, Decreases volume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 1%-
      bindd = , XF86AudioMute, Toggles mute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindd = , XF86MonBrightnessDown, Lowers brightness, exec, brightnessctl set 5%-
      bindd = , XF86MonBrightnessUp, Increases brightness, exec, brightnessctl set 5%+
      bindd = $mainMod, slash,Opens the Special Workspace, togglespecialworkspace
      bindd = $mainMod SHIFT, slash,Moves window to the Special Workspace, movetoworkspace, special
    '';
  home.file."${config.xdg.configHome}/hypr/startup.conf".text =
    /*
    hyprlang
    */
    ''
      # Startup :workspace:workspace
      exec = bash $HOME/.config/hypr/scripts/hypronstart.sh &
      exec = pgrep -x clipse|| ${pkgs.clipse}/bin/clipse -listen
      exec-once = fcitx5 -d
      exec-once = bash $HOME/.config/hypr/scripts/bat_notify.sh --continue &
      exec-once = swww init
      exec-once = ${pkgs.vesktop}/bin/vesktop
      # exec = $HOME/.scripts/background/cron.sh ~/Pictures/Monogatari/
      exec-once = /etc/profiles/per-user/USER_NAME/bin/firefox
      exec-once = /etc/profiles/per-user/USER_NAME/bin/vesktop
      exec = ~/.config/hypr/scripts/sleep.sh &
      exec = eww open bar &
    '';
  home.file."${config.xdg.configHome}/hypr/window_rules.conf".text =
    /*
    hyprlang
    */
    ''
      # Example windowrule v1
      windowrulev2 = float,class:^(.*waypaper.*)$
      windowrulev2 = size 889 629,class:^(.*waypaper.*)
      windowrulev2 = float,class:^(kitty.*)$,title:^(.*clipse.*)$
      windowrulev2 = size 546 552,class:^(kitty.*)$,title:^(.*clipse.*)$
      windowrulev2 = opacity 0.5 0.5,class:^(kitty.*)$,title:^(.*clipse.*)$
      windowrulev2 = float, class:^(.*pavucontrol)$
      windowrulev2 = size 1059 552,class:^(.*pavucontrol)$
      windowrule   = opacity 0.8 0.7, obsidian
      windowrule   = opacity 0.8 0.7, firefox-browser
      windowrule   = opacity 0.8 0.7, firefox
      windowrule   = opacity 0.8 0.7, thunar
      windowrulev2 = size 842 465, class:thunar
      windowrulev2 = float, class:^(thunar)$
      windowrulev2 = opacity 1.0 1.0, class:mpv
      windowrulev2 = opacity 0.8 0.7, class:vesktop
      windowrulev2 = opacity 1.0 1.0, title:^(.*YouTube.*)$
      windowrulev2 = fullscreen,class:^(.*steam_app.*)$
      windowrulev2 = float,class:^(.*steam_app.*)$
      windowrulev2 = opacity 0.8 0.7, class:^.*kitty.*$
      windowrulev2 = opacity 1.0 1.0, class:firefox,title:^(.*S[0-9].*E[0-9].*)$

      # Idle Inhibit
      windowrulev2 = idleinhibit always, title:.*(nh).*
      windowrulev2 = idleinhibit focus, class:.*(steam_app).*
      windowrulev2 = idleinhibit focus, class:firefox,title:^(.*S[0-9].*E[0-9].*)$
      windowrulev2 = idleinhibit focus, class:firefox,title:^(.*YouTube.*)$
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

      # App Workspace Bindings
      windowrule   = workspace 1, ^(.*firefox.*)$
      windowrulev2 = workspace 3, class:^(.*steam_app.*)$
      windowrule   = workspace 8, ^(.*mpv.*)$
      windowrule   = workspace 7, ^(.*vesktop.*)$
      windowrulev2 = workspace 6, class:^(.*YouTube Music.*)$# Example windowrule v2
      # XwaylandVideoBridge
      windowrulev2 = opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$
      windowrulev2 = noanim,class:^(xwaylandvideobridge)$
      windowrulev2 = nofocus,class:^(xwaylandvideobridge)$
      windowrulev2 = noinitialfocus,class:^(xwaylandvideobridge)$
    '';
  home.file."${config.xdg.configHome}/hypr/media_widget.conf".text =
    /*
    hyprlang
    */
    ''
      # vim: filetype=hyprlang
      # Media image
      image {
          monitor =
          path = /tmp/cover.png
          reload_cmd = ~/.config/eww/scripts/mediacontrol coverloc
          size = 64
          border_size = 4
          border_color = rgba(210, 247, 166, 1)
          reload_time = 1
          position = -169, -7
          halign = center
          valign = top
      }
      # Player status
      label {
          monitor =
          text = cmd[update:100] echo "<span foreground='##D0E1AA'>$(bash ~/.config/eww/scripts/mediacontrol statusicon)</span>"
          text_align = right
          color = $white
          font_size = 22
          font_family = JetBrainsMono Nerd Font 10
          position = 170, -25
          halign = center
          valign = top
      }
      shape {
          monitor =
          size = 410, 72
          color = $black
          rounding = -1
          border_size = 2
          border_color = rgba(203, 166, 247, 1)
          rotate = 0
          xray = false # if true, make a "hole" in the background (rectangle of specified size, no rotation)
          position = 0, -05
          halign = center
          valign = top
      }
      # Song title
      label {
          monitor =
          text = cmd[update:100] echo "<b>$(bash ~/.config/eww/scripts/mediacontrol title)</b>"
          text_align = left
          color = rgba(203, 166, 247, 1)
          font_size = 12
          font_family = Dank Mono 10
          position = 0, -55
          halign = center
          valign = top
      }
      # Song artist
      label {
          monitor =
          text = cmd[update:100] echo "<b>$(bash ~/.config/eww/scripts/mediacontrol artist| sd "&" "&amp;")</b>"
          text_align = left
          color = rgba(210, 247, 166, 1)
          font_size = 12
          font_family = Dank Mono 10
          position = 0, -15
          halign = center
          valign = top
      }

      # Song elapsed time
      label {
          monitor =
          text = cmd[update:100] bash ~/.config/eww/scripts/mediacontrol position
          text_align = left
          color = rgba(203, 166, 247, 1)
          font_size = 8
          font_family = JetBrainsMono Nerd Font 10
          position = -90, -33
          halign = center
          valign = top
      }
      # Song duration
      label {
          monitor =
          text = cmd[update:100] bash ~/.config/eww/scripts/mediacontrol length
          text_align = left
          color = rgba(210, 247, 166, 1)
          font_size = 8
          font_family = JetBrainsMono Nerd Font 10

          position = 90, -32
          halign = center
          valign = top
      }
      # Player progress bar
      label {
          monitor =
          text = cmd[update:100] bash ~/.config/eww/scripts/mediacontrol progress
          text_align = left
          color = rgba(203, 166, 247, 1)
          font_size = 5
          font_family = JetBrainsMono Nerd Font 10

          position = 0, -35
          halign = center
          valign = top
      }
    '';
  home.file."${config.xdg.configHome}/hypr/hyprlock.conf".text =
    /*
    hyprlang
    */
    ''
      # vim: filetype=hyprlang
      # source = $HOME/.cache/wal/colors-hyprland.conf

      general {
          grace = 2
      }

      background {
          monitor =
          path = screenshot
          # path = $HOME/Pictures/Monogatari/very_cool.png   # only png supported for now
          color = rgba(0,0,0,0)
          # all these options are taken from hyprland, see https://wiki.hyprland.org/Configuring/Variables/#blur for explanations
          blur_size = 4
          blur_passes = 3 # 0 disables blurring
          noise = 0.0117
          contrast = 1.3000 # Vibrant!!!
          brightness = 0.8000
          vibrancy = 0.2100
          vibrancy_darkness = 0.0
      }
      label {
          monitor =
          text = cmd[update:100000] echo "<i>Flake last updated: $(stat -c %z ~/.dotfiles/flake.lock|awk '{ print $1 }')</i>"
          color = rgba(203, 166, 247, 1)
          font_size = 16
          font_family = Dank Mono
          position = 30, -30
          valign = top
          halign = left
      }

      input-field {
          monitor =
          size = 250, 50
          outline_thickness = 3
          dots_size = 0.2 # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.64 # Scale of dots' absolute size, 0.0 - 1.0
          dots_center = true
          outer_color = rgba(86, 52, 88, 1)
          inner_color = rgba(203, 166, 247, 1)
          font_color = rgba(0,0,0,1)
          fade_on_empty = true
          placeholder_text = <i>Password...</i> # Text rendered in the input box when it's empty.
          # font_family = Dank Mono
          hide_input = false
          position = 0, 95
          halign = center
          valign = bottom
      }

      image {
          monitor =
          border_size = 4
          path = ~/.face.png
          size = 250
          border_color = rgba(210, 247, 166, 1)# rgba(203, 166, 247, 1)
          position = 0, 0
          valign = center
          halign = center
      }
      # Current time
      label {
          monitor =
          text = cmd[update:1000] echo "<b><big> $(date +"%H:%M:%S") </big></b>"
          color = rgba(203, 166, 247, 1)
          font_size = 64
          font_family = JetBrains Mono Nerd Font 10
          position = 0, 30
          valign = bottom
          halign = right
      }

      # User label
      label {
          monitor =
          text = Welcome back, <span text_transform="capitalize" size="larger">$USER</span>
          color = rgba(203, 166, 247, 1)
          font_size = 20
          font_family = Dank Mono 10
          position = -80, 15
          halign = right
          valign = bottom
      }
      # label {
      #     monitor =
      #     text = cmd[update:10000]echo "<i>$(~/.dotfiles/common/scripts/hyprlock_player.sh)</i>"
      #     color = rgba(210, 247, 166, 1)# rgba(203, 166, 247, 1)
      #     font_size = 16
      #     font_family = Dank Mono 10
      #     position = 0, -30
      #     halign = center
      #     valign = top
      # }
      # Type to unlock
      label {
          monitor =
          text = <i>Enter Password or touch YubiKey</i>
          color = rgba(203, 166, 247, 1)
          font_size = 16
          font_family = Dank Mono 10
          position = 0, 30
          halign = center
          valign = bottom
      }
      source = ~/.config/hypr/media_widget.conf
    '';
  home.file."${config.xdg.configHome}/hypr/hypridle.conf".text =
    /*
    hyprlang
    */
    ''
      # vim: filetype=hyprlang
      general {
          lock_cmd = pidof hyprlock || hyprlock       # avoid starting multiple hyprlock instances.
          # before_sleep_cmd = loginctl lock-session    # lock before suspend.
          after_sleep_cmd = hyprctl dispatch dpms on  # to avoid having to press a key twice to turn on the display.
      }

      listener {
          timeout = 300                            # in seconds
          on-timeout = hyprlock # command to run when timeout has passed
          on-resume = notify-send "Returned" "Welcome back!" -i ~/.config/hypr/.hypr.png -a "Hyprlock"
      }

      listener {
          timeout = 450                                 # 7.5 min
          on-timeout = hyprctl dispatch dpms off        # screen off when timeout has passed
          on-resume = hyprctl dispatch dpms on          # screen on when activity is detected after timeout has fired.
      }
    '';
}
