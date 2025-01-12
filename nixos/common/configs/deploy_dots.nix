{
  pkgs,
  config,
  username,
  hostname,
  ...
}: {
  home.file."${config.home.homeDirectory}/.scripts" = {
    source = ../../.. + "/common" + /scripts;
    recursive = true;
  };

  home.file."${config.xdg.configHome}/carapace" = {
    source = ../../.. + "/common" + /carapace;
    recursive = true;
  };
  home.file."${config.xdg.configHome}/notification_icons" = {
    source = ../../.. + "/common" + /notification_icons;
    recursive = true;
  };

  home.file."${config.xdg.configHome}/zsh" = {
    source = ../../.. + "/common" + /zsh;
    recursive = false;
  };
  # NOTE: Phasing out in lieu of ./rofi.nix
  home.file."${config.xdg.configHome}/rofi/steam" = {
    source = ../../.. + "/common/rofi" + /steam;
    recursive = true;
  };

  home.file."${config.home.homeDirectory}/.rtorrent.rc" = {
    source = ../../.. + "/yoitsu/rtorrent/.rtorrent.rc";
    recursive = false;
  };

  home.file."${config.xdg.configHome}/eww" = {
    source = ../../.. + "/${hostname}" + /eww;
    recursive = true;
  };

  home.file."${config.xdg.configHome}/bat/config".text = ''
    --style=header-filename,header-filesize
    --paging=never
  '';
  home.file."${config.xdg.configHome}/yazi/keymap.toml".text =
    /*
    toml
    */
    ''
      [[manager.prepend_keymap]]
      on   = [ "g", "a" ]
      run  = "cd /mnt/NAS/Anime"
      desc = "Cd to Anime"

      [[manager.prepend_keymap]]
      on   = [ "g", "M" ]
      run  = "cd /mnt/NAS/Movies/"
      desc = "Cd to Movies"

      [[manager.prepend_keymap]]
      on   = [ "g", "t" ]
      run  = "cd /mnt/NAS/TVShows/"
      desc = "Cd to TVShows"

      [[manager.prepend_keymap]]
      on   = [ "g", "r" ]
      run  = "cd ~/.rtorrent/download/"
      desc = "Cd to Rtorrent"

      [[manager.prepend_keymap]]
      on   = [ "g", "D" ]
      run  = "cd ~/.dotfiles/"
      desc = "Cd to dots"

      [[manager.prepend_keymap]]
      on   = [ "g", "p" ]
      run  = "cd ~/Pictures"
      desc = "Cd to ~/Pictures"

      [[manager.prepend_keymap]]
      on   = [ "g", "m" ]
      run  = "cd /mnt/NAS/Manga/"
      desc = "Cd to Manga"
    '';
  home.file."${config.home.homeDirectory}/.icons/default/index.theme".text =
    /*
    toml
    */
    ''
      [Icon Theme]
      Name=catppuccin-mocha-mauve
      Comment=Default Cursor Theme
      Inherits=catppuccin-mocha-mauve-cursors
    '';
  home.file."${config.xdg.configHome}/satty/config.toml".text =
    /*
    toml
    */
    ''
      [general]
      # Start Satty in fullscreen mode
      fullscreen = false
      # Exit directly after copy/save action
      early-exit = false
      # Select the tool on startup [possible values: pointer, crop, line, arrow, rectangle, text, marker, blur, brush]
      initial-tool = "brush"
      # Configure the command to be called on copy, for example `wl-copy`
      copy-command = "wl-copy"
      # Increase or decrease the size of the annotations
      annotation-size-factor = 1
      # Filename to use for saving action. Omit to disable saving to file. Might contain format specifiers: https://docs.rs/chrono/latest/chrono/format/strftime/index.html
      output-filename = "/home/${username}/Pictures/Screenshots/Screenshot_%Y-%m-%d-%H-%M-%S.png"
      # After copying the screenshot, save it to a file as well
      save-after-copy = false
      # Hide toolbars by default
      default-hide-toolbars = false
      # The primary highlighter to use, the other is accessible by holding CTRL at the start of a highlight [possible values: block, freehand]
      primary-highlighter = "block"
      disable-notifications = false

      # Font to use for text annotations
      [font]
      family = "Dank Mono"
      style = "Italic"

      # custom colours for the colour palette
      [color-palette]
      palette = [
        "#5cb37f",
        "#d20f39",
        "#74c7ec",
        "#cba6f7",
        "#f9e2af",
        "#D2F7A6",
      ]
    '';
  home.file."${config.xdg.configHome}/nushell/satty.nu".text =
    /*
    nu
    */
    ''
      #!/usr/bin/env nu
      module completions {
        def "nu-complete satty initial_tool" [] {
          [ "pointer" "crop" "line" "arrow" "rectangle" "ellipse" "text" "marker" "blur" "highlight" "brush" ]
        }
        def "nu-complete satty primary_highlighter" [] {
          [ "block" "freehand" ]
        }

        def "nu-complete weather_app locations" [] {
          [ "Calgary" "\"New York\"" "London" "Paris" "Tokyo" "Industry" "Sydney" "Dubai" "Rome" "\"Evans City\"" "Berlin" "Baltimore" "Moscow" "Beijing" "Delhi" "Cairo" "\"Mexico City\"" "\"São Paulo\"" "\"Buenos Aires\"" ]
      }

        def "nu-complete autorenamer numbers" [] {
          [ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 ]
        }

        # Modern Screenshot Annotation. A Screenshot Annotation Tool inspired by Swappy and Flameshot.
        export extern satty [
          --config(-c): string      # Path to the config file. Otherwise will be read from XDG_CONFIG_DIR/satty/config.toml
          --filename(-f): string    # Path to input image or '-' to read from stdin
          --fullscreen              # Start Satty in fullscreen mode
          --output-filename(-o): string # Filename to use for saving action. Omit to disable saving to file. Might contain format specifiers: <https://docs.rs/chrono/latest/chrono/format/strftime/index.html>
          --early-exit              # Exit directly after copy/save action
          --initial-tool: string@"nu-complete satty initial_tool" # Select the tool on startup
          --init-tool: string@"nu-complete satty initial_tool" # Select the tool on startup
          --copy-command: string    # Configure the command to be called on copy, for example `wl-copy`
          --annotation-size-factor: string # Increase or decrease the size of the annotations
          --save-after-copy         # After copying the screenshot, save it to a file as well
          --default-hide-toolbars(-d) # Hide toolbars by default
          --font-family: string     # Font family to use for text annotations
          --font-style: string      # Font style to use for text annotations
          --primary-highlighter: string@"nu-complete satty primary_highlighter" # The primary highlighter to use, secondary is accessible with CTRL
          --disable-notifications   # Disable notifications
          --help(-h)                # Print help
          --version(-V)             # Print version
        ]

      # Video file renamer for library management
      export extern autorenamer [
        --season(-s): int@"nu-complete autorenamer numbers"        # Season of the show to rename
        --path(-p): string                                         # Path to the directory containing your season
        --offset(-o): int@"nu-complete autorenamer numbers"        # An integer with a positive or negative number to offset renaming by. i.e. --ofset 5 changes 'Episode 5.mp4' to 'Episode 10.mp4'
        --dryrun(-d)                                              # Shows the 'whatif' events without actually writing changes to disk
          --help(-h)                                              # Print help
          --version(-V)                                           # Print version
      ]

      # Home Grown CLI weather app written in Rust
      export extern weather_app [
          --bar(-b)       # For use w/ your favorite statusbar.
          --forecast(-f)  # Do you want the forecast?
          --help(-h)      # Prints help information
          --version(-v)   # Prints version information
          --location(-l): string@"nu-complete weather_app locations"  # Choose your location: Defaults to Pittsburgh
        ]
      }

      export use completions *
    '';
  home.file."${config.xdg.configHome}/pipewire/pipewire.conf.d/99-input-denoising.conf".text = ''
    context.modules = [
    {   name = libpipewire-module-filter-chain
        args = {
            node.description =  "Noise Canceling source"
            media.name =  "Noise Canceling source"
            filter.graph = {
                nodes = [
                    {
                        type = ladspa
                        name = rnnoise
                        plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so"
                        label = noise_suppressor_mono
                        control = {
                            "VAD Threshold (%)" = 40.0
                            "VAD Grace Period (ms)" = 100
                            "Retroactive VAD Grace (ms)" = 0
                        }
                    }
                ]
            }
            capture.props = {
                node.name =  "capture.rnnoise_source"
                node.passive = true
                audio.rate = 48000
            }
            playback.props = {
                node.name =  "rnnoise_source"
                media.class = Audio/Source
                audio.rate = 48000
            }
        }
    }
    ]   '';
}
