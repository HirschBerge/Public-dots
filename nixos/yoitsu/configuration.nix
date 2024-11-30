# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
#  ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗
#  ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝
#  ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗
#  ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║
#  ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║
#  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
#
{
  username,
  stateVersion,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../common/common-conf.nix
    ./8bitdo.nix
    ./configs/gaming.nix
  ];
  users.users.${username}. packages = with pkgs; [
    starship
    rocmPackages.rocm-smi
    streamcontroller
    heroic-unwrapped
    piper
    firefox
    #  thunderbird
  ];
  nixos-boot = {
    enable = true;

    # Different colors
    # bgColor.red   = 100; # 0 - 255
    # bgColor.green = 100; # 0 - 255
    # bgColor.blue  = 100; # 0 - 255

    # INFO: Options are: dna, dragon, hexa_retro, lone, pixels
    theme = "dragon";
    # If you want to make sure the theme is seen when your computer starts too fast
    duration = 3.0; # in seconds
  };
  services.ratbagd.enable = true;
  # Allow unfree packages
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/30 * * * *      ${username}    /home/${username}/.scripts/.venv/bin/python3 /home/${username}/.scripts/manga_update.py"
      "* * * * *        ${username}    if [ -d ~/Desktop ]; then rm -rf ~/Desktop; fi"
    ];
  };
  # List services that you want to enable:
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
  system.stateVersion = stateVersion; # Did you read the comment?
}
