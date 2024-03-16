{ pkgs, lib, config, hostname, ... }:
{
  home.file."${config.home.homeDirectory}/.scripts" = {
    source = ../../.. + "/${hostname}" + /scripts;
    recursive = true;
  };
  home.file."${config.home.homeDirectory}/.local/bin" = {
    source = ../../.. + "/${hostname}" + /bin;
    recursive = true;
  };

  # home.file."${config.xdg.configHome}/nvim" = {
  #   source = ../../.. + "/${hostname}" + /nvim;
  #   recursive = true;
  # };

  home.file."${config.xdg.configHome}/swaync" = {
    source = ../../.. + "/${hostname}" + /swaync;
    recursive = true;
  };

  home.file."${config.xdg.configHome}/zsh" = {
    source = ../../.. + "/${hostname}" + /zsh;
    recursive = false;
  };

  home.file."${config.xdg.configHome}/rofi" = {
    source = ../../.. + "/${hostname}" + /rofi;
    recursive = true;
  };

  home.file."${config.xdg.configHome}/eww" = {
    source = ../../.. + "/${hostname}" + /eww;
    recursive = true;
  };

  home.file."${config.xdg.configHome}/lf" = {
    source = ../../.. + "/${hostname}" + /lf;
    recursive = true;
  };
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
    '';
  # home.file."${config.xdg.configHome}/" = {
  #   source = ../../.. + "/${hostname}" + /;
  #   recursive = true;
  # };
}
