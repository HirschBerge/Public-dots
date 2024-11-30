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
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common/common-conf.nix
    ./configs/battery.nix
  ];
  nixos-boot = {
    enable = true;
    # Different colors
    # bgColor.red   = 100; # 0 - 255
    # bgColor.green = 100; # 0 - 255
    # bgColor.blue  = 100; # 0 - 255

    # INFO: Options are: dna, dragon, hexa_retro, lone, pixels
    theme = "hexa_retro";
    # If you want to make sure the theme is seen when your computer starts too fast
    duration = 3.0; # in seconds
  };

  users.users.${username}. packages = with pkgs; [
    acpi
    firefox
  ];
  services.cron = {
    enable = true;
    systemCronJobs = [
      # "*/30 * * * *      ${username}    /home/${username}/.scripts/.venv/bin/python3 /home/${username}/.scripts/manga_update.py"
      "*/5 * * * *      ${username}     /home/${username}/.scripts/bat_notify.sh"
      "* * * * *        ${username}    if [ -d ~/Desktop ]; then rm -rf ~/Desktop; fi"
    ];
  };
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };
  services = {
    thermald.enable = true;
    power-profiles-daemon.enable = false;
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "powersave";
          turbo = "auto";
        };
      };
    };
    system76-scheduler = {
      enable = true;
      useStockConfig = true;
    };
  };
}
