{ config, ... }:
let
    plug_bar = /*bash*/''
    default_tab_template {
        pane size=1 borderless=true {
            plugin location="https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm"{
                format_left   "{mode} #[fg=#89B4FA,bold]{session}"
                format_center "{tabs}"
                format_right  "{command_git_name}{command_git_branch}{command_git_files}{command_git_add}{command_git_sub}{datetime}"
                format_space  ""

                border_enabled  "false"
                border_char     "─"
                border_format   "#[fg=#6C7086]{char}"
                border_position "top"

                hide_frame_for_single_pane "false"

                mode_normal  "#[bg=#cba6f7,fg=black,bold]Session:"
                mode_locked  "#[bg=#cba6f7,fg=black,bold]Session Locked:"
                mode_tmux    "#[bg=#ffc387,fg=black,bold]Session:"

                tab_normal   "#[fg=#D2F7A6] {name} "
                tab_active   "#[fg=#cba6f7,bold,italic] {name} "

                command_git_branch_command     "bash -c 'gitstatus --branch |xargs'"
                command_git_branch_format      "#[fg=#cba6f7] {stdout} "
                command_git_branch_interval    "10"
                command_git_branch_rendermode  "static"

                command_git_files_command     "bash -c 'gitstatus --files |xargs'"
                command_git_files_format      "#[fg=#ffc387] {stdout} "
                command_git_files_interval    "10"
                command_git_files_rendermode  "static"

                command_git_add_command     "bash -c 'gitstatus --add |xargs'"
                command_git_add_format      "#[fg=green] {stdout} "
                command_git_add_interval    "10"
                command_git_add_rendermode  "static"

                command_git_sub_command     "bash -c 'gitstatus --sub |xargs'"
                command_git_sub_format      "#[fg=red] {stdout} "
                command_git_sub_interval    "10"
                command_git_sub_rendermode  "static"

                command_git_name_command     "bash -c 'gitstatus --name |xargs'"
                command_git_name_format      "#[fg=#cba6f7] {stdout} "
                command_git_name_interval    "10"
                command_git_name_rendermode  "static"

                datetime        "#[fg=#df5b61,bold] {format} "
                datetime_format "%A, %d %b %Y %H:%M"
                datetime_timezone "America/New_York"
            }
        }
        children
    }
    '';
in
{
  programs.zellij = {
    enable = true;
  };
  home.file."${config.xdg.configHome}/zellij/config.kdl".text = /*bash*/ ''
default_shell "zsh"
keybinds {
    normal {
        bind "Enter" {  // Intercept `Enter`.
            WriteChars "\u{000D}";  // Passthru `Enter`.
            MessagePlugin "autolock" {};  // Activate the autolock plugin.
        }
        // Note: You may want to bind/intercept/relay other keys to activate this plugin,
        // like `Ctrl+r` which opens shell history in Atuin / FZF. For example:
        // bind "Ctrl r" {  // Intercept `Ctrl+r`.
        //     WriteChars "\u{0012}";  // Passthru `Ctrl+r`
        //     MessagePlugin "autolock" {};  // Activate the autolock plugin.
        // }
    }
  shared{
      bind "Alt f" {
          SwitchToMode "Normal"
              ToggleFocusFullscreen 
      }
  }
  unbind "Ctrl g"
}
plugins {
    "filepicker"
    "tab-bar"
    "status-bar"
    "strider"
    "compact-bar"
    "session-manager"
    autolock location="https://github.com/fresh2dev/zellij-autolock/releases/latest/download/zellij-autolock.wasm" {
        triggers "nvim|vim|v"  // Lock when any open these programs open. They are expected to unlock themselves when closed (e.g., using zellij.vim plugin).
        watch_triggers "fzf|zoxide|atuin"  // Lock when any of these open and monitor until closed.
        watch_interval "1.0"  // When monitoring, check every X seconds.
    }
    //...
}
theme "catppuccin-mocha"
      '';
  home.file."${config.xdg.configHome}/zellij/layouts/default.kdl".text = /*bash*/ ''
layout {
    tab name="Main" focus=true hide_floating_panes=true {
        pane split_direction="vertical" {
            pane command="v" size="60%" {
            }
            pane size="40%" {
                pane focus=true size="50%" 
                pane command="lf" size="50%" cwd="/home/USER_NAME/.dotfiles/" {
                }
            }
        }
        floating_panes {
            pane focus=false command="lazygit"{
                height 35
                width 175
                x 19
                y 6
            }
        }
    }
    tab name="Scratchpad" hide_floating_panes=true {
        pane
    }
    ${plug_bar}
}
    '';
    home.file."${config.xdg.configHome}/zellij/layouts/rust.kdl".text = /*bash*/ ''

layout {
    tab name="Rust Dev" focus=true hide_floating_panes=true {
        pane split_direction="vertical" focus=true {
            pane command="nix" size="60%" {
                args "develop" "-c" "/run/current-system/sw/bin/v" "src/main.rs"
            }
            pane size="40%" {
                pane command="nix" size="50%" {
                    args "develop" "-c" "bacon" "run"
                }
                pane command="nix" size="50%" {
                    args "develop" "-c" "bacon" "clippy"
                }
            }
        }
        floating_panes {
            pane command="lazygit" {
                height 35
                width 175
                x 19
                y 6
            }
        }
    }
    tab name="Scratchpad" hide_floating_panes=true {
        pane
    }
    ${plug_bar}
}
    '';
}
