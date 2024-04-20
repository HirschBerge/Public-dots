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
{ inputs,
  outputs,
  config,
  lib,
  pkgs,
  hostname,
  username,
  system,
  stateVersion,
  ... }:
let
  themes = pkgs.callPackage  ../common/configs/themes.nix {};

  # For outputting list of packages.
  # packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
  # sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
  # formatted = builtins.concatStringsSep "\n" sortedUnique;
in

{
  imports =
    [ # Include the results of the hardware scan.
        ../common/common_pkgs.nix
        ./hardware-configuration.nix
        ./8bitdo.nix
        ../common/wayland.nix
        ./configs/gaming.nix
        ../common/configs/fonts.nix
        ../common/systemCat.nix
    ];
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 1;
  };
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
    };
  };
    # Writes current *system* packagesto /etc/current-system/packages
  environment.etc."current-system-packages".text =
  let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in
    formatted;
  environment = {
    sessionVariables = {
      HOME_MANAGER_BACKUP_EXT = "backup";
      FLAKE = "/home/${username}/.dotfiles";
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
          command = "/run/current-system/sw/bin/ln";
          options = [ "NOPASSWD" ];
        }
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
          command = "/run/current-system/sw/bin/nix-channel";
          options = [ "NOPASSWD" ];
        }
      #   {
      #     command = "/home/${username}/.local/bin/xremap";
      #     options = [ "NOPASSWD" ];
      #   }
      ];
      groups = [ "wheel" ];
    }];
  };
  networking.hostName = "${hostname}"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
      theme = "abstractguts-themes";
    };
  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
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
      rocmPackages.rocm-smi
      firefox
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.allowUnfreePredicate = _: true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.overlays = [
    (self: super: {
      waybar = super.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    })
  ];
  environment.systemPackages = with pkgs; [
      # see ../common/common_pkgs.nix
      themes.abstractguts-themes
      godot_4
  ];

  # XDG portal
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk];
    config.common.default = "*";
    # configPackages = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
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
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            capslock = "overload(meta, esc)";
            esc = "overload(esc, capslock)";
          };
        };
      };
    };
  }; 
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";    
    };
  };
  services.pcscd.enable = true;
  # List services that you want to enable:
  services.dbus.packages = [
    pkgs.dbus.out
    config.system.path
  ];
  services.cron = {
    enable = true;
    systemCronJobs = [
      "* * * * *         ${username}    date >> /home/${username}/.cache/test.log"
      "*/30 * * * *      ${username}    /home/${username}/.scripts/.venv/bin/python3 /home/${username}/.scripts/manga_update.py"
    ];
  };
  # List services that you want to enable:
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?
  # environment.etc."current-packages".text = formatted;
}
