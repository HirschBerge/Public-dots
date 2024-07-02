{ pkgs, config, hostname, ... }:
{
  home.file."${config.home.homeDirectory}/.scripts" = {
    source = ../../.. + "/common" + /scripts;
    recursive = true;
  };

  home.file."${config.xdg.configHome}/swaync" = {
    source = ../../.. + "/common" + /swaync;
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

  # home.file."${config.xdg.configHome}/zellij/config.kdl" = {
  #   source = ../../.. + "/common" + /zellij/config.kdl;
  #   recursive = false;
  # };

  home.file."${config.xdg.configHome}/eww" = {
    source = ../../.. + "/${hostname}" + /eww;
    recursive = true;
  };

  home.file."${config.xdg.configHome}/lf" = {
    source = ../../.. + "/common" + /lf;
    recursive = true;
  };
  home.file."${config.xdg.configHome}/bat/config".text = ''
--style=header-filename,header-filesize
--paging=never
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
]
r   '';
    }
