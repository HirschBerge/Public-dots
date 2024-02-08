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

  home.file."${config.xdg.configHome}/nvim" = {
    source = ../../.. + "/${hostname}" + /nvim;
    recursive = true;
  };

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

  # home.file."${config.xdg.configHome}/" = {
  #   source = ../../.. + "/${hostname}" + /;
  #   recursive = true;
  # };
}
