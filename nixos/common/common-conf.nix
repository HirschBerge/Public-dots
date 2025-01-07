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
  hostname,
  username,
  discord,
  inputs,
  stateVersion,
  ...
}: let
  themes = pkgs.callPackage ./configs/themes.nix {};
  custom_pkgs = pkgs.callPackage ./custom_pkgs.nix {};
in {
  imports = [
    ./configs/syncthing.nix
    ./wayland.nix
    ./configs/fonts.nix
    ./systemCat.nix
  ];
  nix = {
    settings = {
      substituters = [
        "https://hyprland.cachix.org"
        "https://wezterm.cachix.org"
        "https://ghostty.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      ];
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "@wheel"];
    };
  };
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 1;
  };
  environment = {
    systemPackages = with pkgs; [
      inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
      themes.abstractguts-themes
      custom_pkgs.scooter
      custom_pkgs.talecast
      catppuccin-cursors.mochaMauve
      tlrc
      clipse
      nmap-formatter
      zig
      castero
      imagemagick
      lua-language-server
      kitty
      vesktop
      neovim
      inputs.ghostty.packages.x86_64-linux.default
      helix
      wget
      home-manager
      traceroute
      python312
      obs-studio
      ripgrep
      du-dust
      cmake
      lm_sensors
      ffmpeg
      pciutils
      tokei
      kondo
      mpv
      sd
      file
      zellij
      zoxide
      hyprlock
      hypridle
      # bat-extras.batgrep
      bat-extras.batman
      bat-extras.batpipe
      bat-extras.batwatch
      signal-desktop
      # bat-extras.prettybat
      sshs
      atac
      termshark
      portal
      yazi
      anki
      protonmail-desktop
      rqbit
    ];
    # Allows hyprlock to use pam
    etc = {
      "pam.d/hyprlock" = {
        text = ''
          auth include login
        '';
        # Optionally, specify the permissions you want for the file
        # by setting the `mode` attribute:
        mode = "0777";
      };
    };
    sessionVariables = {
      HOME_MANAGER_BACKUP_EXT = "backup";
      FLAKE = "/home/${username}/.dotfiles";
      TACO_BELL = "${discord}";
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
  security = {
    rtkit.enable = true;
    pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      swaylock = {
        text = ''
          auth include login
        '';
      };
    };
    sudo = {
      enable = true;
      extraRules = [
        {
          commands = [
            {
              command = "${pkgs.systemd}/bin/systemctl suspend";
              options = ["NOPASSWD"];
            }
            {
              command = "${pkgs.systemd}/bin/reboot";
              options = ["NOPASSWD"];
            }
            {
              command = "${pkgs.systemd}/bin/poweroff";
              options = ["NOPASSWD"];
            }
            {
              command = "/run/current-system/sw/bin/nixos-rebuild";
              options = ["NOPASSWD"];
            }
            {
              command = "${pkgs.neovim}/bin/nvim";
              options = ["NOPASSWD"];
            }
            {
              command = "${pkgs.systemd}/bin/systemctl";
              options = ["NOPASSWD"];
            }
            {
              command = "/run/current-system/sw/bin/ln";
              options = ["NOPASSWD"];
            }
            {
              command = "/run/current-system/sw/bin/nix-channel";
              options = ["NOPASSWD"];
            }
          ];
          groups = ["wheel"];
        }
      ];
    };
  };
  networking.hostName = "${hostname}"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
    inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5.addons = with pkgs; [
        fcitx5-anthy
        fcitx5-gtk
      ];
    };
  };

  services = {
    dbus.packages = [
      pkgs.dbus.out
      config.system.path
    ];
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    pcscd.enable = true;
    keyd = {
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
    displayManager.sddm = {
      enable = true;
      enableHidpi = true;
      wayland.enable = true;
      theme = "abstractguts-themes";
    };
    blueman.enable = true;
    pulseaudio.enable = false;
    xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.extraConfig = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = ["hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
        };
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "${username}";
    extraGroups = ["networkmanager" "wheel" "keyd"];
  };
  nixpkgs.config.allowUnfree = true;

  documentation.man = {
    enable = true;
    generateCaches = true;
  };
  # XDG portal
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.common.default = "*";
    # configPackages = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  system.stateVersion = stateVersion; # Did you read the comment?

  programs = {
    zsh.enable = true;
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 5";
      flake = "/home/${username}/.dotfiles";
    };
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez;
    settings = {
      General = {
        Experimental = true;
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
}
