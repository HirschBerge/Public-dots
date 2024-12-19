{
  pkgs,
  config,
  # inputs,
  ...
}: let
  term = "wezterm";
  term_open = "${term} start -- ";
  term_open_class = "${term} -n --config enable_tab_bar=false start --class clipse -- ";
in {
  home.packages = with pkgs; [
    wl-clipboard
    waypaper
    grim
    slurp
    swww
    # hyprland # Comment out when back to using flake version
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    extraConfig =
      /*
      hyprlang
      */
      ''
        # vim: filetype=hyprlang
        monitor=DP-1,2560x1080@200,0x0,1,vrr,1
        monitor=DP-3,2560x1080@200,0x1080,1,vrr,1
        source = ~/.config/hypr/binds.conf
        source = ~/.config/hypr/window_rules.conf
        source = ~/.config/hypr/startup.conf
        source = ~/.config/hypr/workspaces.conf

        # Some default env vars.
        env = WLR_DRM_NO_ATOMIC,1
        env = HYPRCURSOR_THEME,catppuccin-mocha-mauve
        env = HYPRCURSOR_SIZE,24
        env = XDG_SESSION_TYPE,wayland
        env = WLR_NO_HARDWARE_CURSORS,1

        # For all categories, see https://wiki.hyprland.org/Configuring/Variables/

        input {
            kb_layout = us
            kb_variant =
            kb_model =
            kb_rules =
            # kb_options = caps:Super_L
            follow_mouse = 1
            accel_profile = flat
            force_no_accel = true
            touchpad {
                natural_scroll = no
            }
            sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
        }
        misc {
            mouse_move_enables_dpms = false
            # key_press_enables_dpms = true
        }
        general {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            # gaps_in = 5
            # gaps_out = 15
            border_size = 3
            col.active_border = rgb(711C91) rgb(EA00D9) rgb(0abdc6) 45deg
            col.inactive_border = rgb(133e7c) rgb(091833) 45deg
            layout = dwindle
            allow_tearing = false
        }
        decoration {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            # blur_ignore_opacity = true
            rounding = 10
            shadow {
            enabled=true
            range = 4
            render_power = 3
            # col.shadow = rgba(1a1a1aee)
        }
            blur {
              enabled = true
              size = 12
              passes = 3
              new_optimizations = on
              noise = 0.05
              ignore_opacity = true
            }
            # fullscreen_opacity = 0.7
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

        # Example per-device config
        # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
        blurls = dashboard
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
      # vim: filetype=hyprlang
      $mainMod = SUPER
      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more

      bind = ALT, escape, fullscreenstate, 0 2
      # bindd = $mainMod, Return,Opens Kitty, exec, ${pkgs.kitty}/bin/kitty
      bindd = $mainMod, Return,Opens ${term}, exec, ${term}
      bindd = $mainMod, O, Kills the Active Window, killactive,
      bindd = $mainMod, M, Exits Hyprland, exit,
      bindd = $mainMod, N, Opens Dashboard, exec, ~/.config/eww/scripts/launch_dashboard
      bindd = $mainMod, R, Reloads Hyprland, exec, hyprctl reload
      bindd = $mainMod, S, Searches Nixpkgs with nh, exec, ~/.config/eww/scripts/search_nixpkgs.sh
      bindd = $mainMod, G, Opens a game launcher, exec, ~/.config/hypr/scripts/gamelauncher.sh 2
      # bindd = $mainMod, R, exec, wofi --show drun
      bindd = $mainMod, P, Toggles pseudo tiling, pseudo, # dwindle
      bindd = $mainMod SHIFT, J, Toggles split type, togglesplit, # dwindle
      bindd = $mainMod, V, Opens the Clipse clipboard manager, exec, ${term_open_class} zsh -c '${pkgs.clipse}/bin/clipse $PPID' # bindd the open clipboard operation to a nice key.
      bindd = $mainMod, I, Starts screen recording, exec, ~/.scripts/scrn_record.sh
      bindd = $mainMod, C, Opens Helix in ${term}, exec, ${term_open} ${pkgs.helix}/bin/hx ~/.dotfiles/nixos
      # Move focus with mainMod + arrow keys
      bindd = $mainMod, H, Focuses left, movefocus, l
      bindd = $mainMod, L, Focuses right, movefocus, r
      bindd = $mainMod, K, Focuses up, movefocus, u
      bindd = $mainMod, J, Focuses down, movefocus, d
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
      bind = $mainMod SHIFT, space,togglefloating
      # Discord PPT

      # FKey binds
      bindd = $mainMod, F1, Shows Hyprland Keybinds, exec, hyprland_bindings
      bindd = $mainMod, F2, Dmenu Mount, exec, ~/.local/bin/dmenumount
      bindd = $mainMod, F3, Dmenu Umount, exec, ~/.local/bin/dmenuumount

      # Other
      bindd = $mainMod, T, Launches Thunar, exec, ${pkgs.xfce.thunar}/bin/thunar
      bindd = $mainMod, B, Launches Btop, exec, ${term_open} ${pkgs.btop}/bin/btop
      bindd = $mainMod SHIFT, H, Launches Eww, exec, exec = eww open sidebar ; eww -c ~/.config/eww/bar/ open bar; eww open notifications


      # bindd = $mainMod, U, exec, brave
      bindd = $mainMod, U, Launches Firefox, exec, ${pkgs.firefox}/bin/firefox
      bindd = $mainMod, D, Launches Window Finder, exec, find_window
      bindd = ALT, space, Launches Rofi, exec, rofi -show drun window calc emoji
      bindd = $mainMod, Y, Launches MPV youtube Script, exec, yt
      bindd = ,XF86Calculator, Calculator, exec, rofi -show calc
      bindd = $mainMod,F,Fullscreens window, fullscreen
      bindd = $mainMod, TAB, Switches to previous workspace, workspace, previous
      bindd = $mainMod SHIFT, S, Takes a screenshot of selected area, exec, ~/.config/hypr/scripts/screenshot --area
      bindd = $mainMod SHIFT, W, Takes a screenshot of selected window, exec, ~/.config/hypr/scripts/screenshot --win
      bindd = $mainMod SHIFT, A, Launches Waypaper, exec, ${pkgs.waypaper}/bin/waypaper
      bindd = $mainMod,x, Logout Window, exec, ${pkgs.wlogout}/bin/wlogout
      bindd = $mainMod SHIFT,L, Locks Screen with Hyprlock, exec, ${pkgs.hyprlock}/bin/hyprlock
      bindd = $mainMod, slash,Opens the Special Workspace, togglespecialworkspace
      bindd = $mainMod SHIFT, slash,Moves window to the Special Workspace, movetoworkspace, special
    '';
  home.file."${config.xdg.configHome}/hypr/startup.conf".text =
    /*
    hyprlang
    */
    ''
      # vim: filetype=hyprlang
      exec = bash $HOME/.config/hypr/scripts/hypronstart.sh
      # exec-once = [float;workspace special silent] firefox -new-window https://chatgpt.com
      exec-once = fcitx5 -d
      exec-once = streamcontroller -b
      exec = pgrep -x clipse || ${pkgs.clipse}/bin/clipse -listen
      exec-once = ${pkgs.swww}/bin/swww init
      exec-once = ${pkgs.openrgb}/bin/openrgb -p ~/.config/OpenRGB/Purple.orp
      # exec = $HOME/.scripts/background/cron.sh ~/Pictures/Space/
      exec-once = ${pkgs.vesktop}/bin/vesktop &
      # exec-once = /etc/profiles/per-user/USER_NAME/bin/brave
      exec-once = [workspace 1 silent ] ${pkgs.firefox}/bin/firefox &
      exec = ~/.config/hypr/scripts/sleep.sh & #Systemctl service works now for some reason
      exec-once = ${pkgs.protonmail-desktop}/bin/proton-mail
      exec-once = wezterm
    '';
  home.file."${config.xdg.configHome}/hypr/window_rules.conf".text =
    /*
    hyprlang
    */
    ''
      # vim: filetype=hyprlang

      # Example windowrule v1
      windowrulev2 = float,class:^(.*waypaper.*)$
      windowrulev2 = size 889 629,class:^(.*waypaper.*)
      windowrulev2 = tile,class:^(.*Warp.*)$
      windowrulev2 = float,class:^(clipse.*)
      windowrulev2 = size 546 552,class:^(clipse.*)
      windowrulev2 = opacity 0.5 0.5,class:^(clipse.*)
      # windowrulev2 = size 546 552,class:^(kitty.*)$,title:^(.*clipse.*)$
      # windowrulev2 = opacity 0.5 0.5,class:^(kitty.*)$,title:^(.*clipse.*)$
      windowrulev2 = float, class:^(.*pavucontrol)$
      windowrulev2 = size 1059 552,class:^(.*pavucontrol)$
      windowrulev2 = float, class:^(.*desktop-portal-gtk.*)$
      windowrule = opacity 0.9 0.8, firefox
      windowrulev2 = opacity 0.95 1.0, class:vesktop
      windowrulev2 = opacity 1.0 1.0, title:^(.*YouTube.*)$
      windowrulev2 = opacity 1.0 1.0, class:firefox,title:^(.*S[0-9].*E[0-9].*)$
      # windowrulev2 = float, class:^(*.steam_app.*)$
      windowrulev2 = fullscreen, class:^(*.steam_app.*)$
      windowrulev2 = opacity 1.0 1.0 , class:^(*.steam_app.*)$
      windowrulev2 = float, class:(steam)
      windowrulev2 = tile, class:(steam),title:^(.*Steam.*)$
      windowrulev2 = size 842 465, class:thunar
      windowrulev2 = opacity 0.83 0.83, class:thunar
      windowrulev2 = opacity 0.95 0.93, title:^(.*nvim.*)$
      windowrulev2 = float,class:^(thunar)$
      windowrulev2 = size 842 465, class:Thunar
      windowrulev2 = opacity 0.83 0.83, class:Thunar
      windowrulev2 = float,class:^(Thunar)$
      windowrulev2 = opacity 1.0 1.0, class:^(mpv)$
      windowrule = workspace 1, ^(.*firefox.*)$
      windowrulev2 = workspace 3, class:^(.*steam_app.*)$
      windowrule = workspace 9, ^(.*mpv.*)$
      windowrule = workspace 7, ^(.*vesktop.*)$
      windowrulev2 = workspace special, class:^(.*YouTube Music.*)$
      windowrulev2 = float, title:^(.*ChatGPT.*)
      windowrulev2 = workspace special,title:^(.*GPT.*)
      windowrulev2 = size 983 993,title:^(.*GPT.*)

      # XWaylandBridge
      windowrulev2 = opacity 0.75 0.6, class:^.*${term}.*$
      windowrulev2 = opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$
      windowrulev2 = noanim,class:^(xwaylandvideobridge)$
      windowrulev2 = nofocus,class:^(xwaylandvideobridge)$
      windowrulev2 = noinitialfocus,class:^(xwaylandvideobridge)$

      # Fix steam menu
      windowrulev2 = stayfocused, title:^()$,class:^(steam)$
      windowrulev2 = minsize 1 1, title:^()$,class:^(steam)$

      # Idle Inhibit

      windowrulev2 = idleinhibit always, title:.*(nh).*
      windowrulev2 = idleinhibit focus, title:.*(yuzu).*
      windowrulev2 = idleinhibit focus, class:.*(steam_app).*
      windowrulev2 = idleinhibit always, class:firefox,title:^(.*S[0-9].*E[0-9].*)$
      windowrulev2 = idleinhibit always, class:firefox,title:^(.*Google Meet.*)$
      windowrulev2 = idleinhibit always, class:firefox,title:^(.*YouTube.*)$
    '';
  home.file."${config.xdg.configHome}/hypr/workspaces.conf".text =
    /*
    hyprlang
    */
    ''
      # vim: filetype=hyprlang
      # Workspace Binding.
      workspace = 1,monitor:DP-3,rounding:true,decorate:true,gapsin:1,gapsout:8
      workspace = 2,monitor:DP-3,rounding:true,decorate:true,gapsin:1,gapsout:8
      workspace = 3,monitor:DP-3,rounding:true,decorate:true,gapsin:1,gapsout:8
      workspace = 4,monitor:DP-3,rounding:true,decorate:true,gapsin:1,gapsout:8
      workspace = 5,monitor:DP-3,rounding:true,decorate:true,gapsin:1,gapsout:8
      workspace = 6,monitor:DP-1,rounding:true,decorate:true,gapsin:0,gapsout:0
      workspace = 7,monitor:DP-1,rounding:true,decorate:true,gapsin:0,gapsout:0
      workspace = 8,monitor:DP-1,rounding:true,decorate:true,gapsin:0,gapsout:0
      workspace = 9,monitor:DP-1,rounding:true,decorate:true,gapsin:0,gapsout:0
      workspace = 10,monitor:DP-1,rounding:true,decorate:true,gapsin:0,gapsout:0
    '';

  home.file."${config.xdg.configHome}/hypr/media_widget.conf".text =
    /*
    hyprlang
    */
    ''
      # vim: filetype=hyprlang
      # Media image
      image {
          monitor = DP-3
          path = /tmp/cover.png
          reload_cmd = ~/.config/eww/scripts/mediacontrol coverloc
          size = 64
          border_size = 4
          border_color = rgba(210, 247, 166, 1)
          reload_time = 5
          position = -169, -7
          halign = center
          valign = top
      }
      # Player status
      label {
          monitor = DP-3
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
          monitor = DP-3
          size = 410, 72
          color = rgba(17, 17, 27, 1)
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
          monitor = DP-3
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
          monitor = DP-3
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
          monitor = DP-3
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
          monitor = DP-3
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
          monitor = DP-3
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
          monitor = DP-3
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
          monitor = DP-3
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
          monitor = DP-3
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
          monitor = DP-3
          text = Welcome back, <span text_transform="capitalize" size="larger">$USER</span>
          color = rgba(203, 166, 247, 1)
          font_size = 20
          font_family = Dank Mono 10
          position = -80, 15
          halign = right
          valign = bottom
      }
      # label {
      #     monitor = DP-3
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
          monitor = DP-3
          text = <i>Log in here</i>
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
