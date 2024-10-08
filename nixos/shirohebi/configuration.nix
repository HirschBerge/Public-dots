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
  config,
  pkgs,
  inputs,
  hostname,
  username,
  discord,
  ... }:
let
  themes = pkgs.callPackage  ../common/configs/themes.nix {};
in

{
  imports =
    [
        ./hardware-configuration.nix
        ../common/configs/syncthing.nix
        ../common/common_pkgs.nix
        ../common/wayland.nix
        ../common/configs/fonts.nix
        ./configs/battery.nix
        ../common/systemCat.nix
    ];
  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 1;
  };
  nixos-boot = {
    enable  = true;
    # Different colors
    # bgColor.red   = 100; # 0 - 255
    # bgColor.green = 100; # 0 - 255
    # bgColor.blue  = 100; # 0 - 255

    # INFO: Options are: dna, dragon, hexa_retro, lone, pixels
    theme = "hexa_retro";
    # If you want to make sure the theme is seen when your computer starts too fast
    duration = 3.0; # in seconds
  };
  environment = {
    sessionVariables = {
      HOME_MANAGER_BACKUP_EXT = "backup";
      FLAKE = "/home/${username}/.dotfiles";
      TACO_BELL = "${discord}GNVZjd5Yi1tWWNSYmFHMmREX09XUkFEVFJ4amtwMW1qamhlTTB4RklkWVV6VWlYRgo=";
      # WARP_ENABLE_WAYLAND = 1;
      LD_LIBRARY_PATH = "${pkgs.wayland}/lib";
    };
    variables = {
      EDITOR = "v";
      BROWSER = "firefox";
      TERMINAL = "kitty";
      TERM = "kitty";
    };
  };
  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        {
          command = "${pkgs.systemd}/bin/systemctl suspend";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/poweroff";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.neovim}/bin/nvim";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/ln";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nix-channel";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }];
  };
  networking.hostName = "${hostname}"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
   services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
   services.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
    wayland.enable = true;
    theme = "abstractguts-themes";
   };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the ezample session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.zsh.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "${username}";
    extraGroups = [ "networkmanager" "wheel" "keyd" ];
    packages = with pkgs; [
      acpi
      firefox
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages =  [
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    pkgs.catppuccin-cursors.mochaMauve
      themes.abstractguts-themes
  ];
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
    };
  };
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            capslock = "overload(meta, esc)";
          };
        };
      };
    };
  };
  services.udev.packages = [ pkgs.yubikey-personalization ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
    swaylock = {
      text = ''
        auth include login
      '';
    };
  };
  environment.etc = {
    "pam.d/hyprlock" = {
      text = ''
        auth include login
        '';
# Optionally, specify the permissions you want for the file
# by setting the `mode` attribute:
      mode = "077m";
    };
  };
  programs.mtr.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";    
    };
  };
  # List services that you want to enable:
  services.dbus.packages = [
    pkgs.dbus.out
    config.system.path
  ];
  services.cron = {
    enable = true;
    systemCronJobs = [
      "* * * * *         ${username}    date >> /home/${username}/.cache/test.log"
      # "*/30 * * * *      ${username}    /home/${username}/.scripts/.venv/bin/python3 /home/${username}/.scripts/manga_update.py"
      "*/5 * * * *      ${username}     /home/${username}/.scripts/bat_notify.sh"
      "* * * * *        ${username}    if [ -d ~/Desktop ]; then rm -rf ~/Desktop; fi"
    ];
  };
  system.stateVersion = "23.05"; # Did you read the comment?

}
