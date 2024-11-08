{username, ...}: let
  # NOTE: 3DS, PS2, PS3, PSX, SNES,Switch, WII, WIIU
  platform = "PS2";
  #NOTE: Please consult your directory structure.
  subdir = "Tales of the Abyss upgrade";
in {
  services = {
    syncthing = {
      enable = true;
      user = "${username}";
      dataDir = "/home/${username}/Documents";
      configDir = "/home/${username}/.config/syncthing";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      guiAddress = "0.0.0.0:8384";
      settings = {
        options = {
          relaysEnabled = false;
          urAccepted = -1;
          globalAnnounceEnabled = false;
        };
        devices = {
          "yoitsu" = {
            id = "6NMSD7M-M6LM7MG-BFZVSXY-C4IDJBS-VILNB7P-HGKNH2K-KE7V46J-K3HUVQW";
            addresses = "tcp://10.10.0.69:22000";
          };
          #TODO: Uncomment when needed
          # "steamdeck" = {
          #     id = "FJLCKT4-T55B7JF-PU5K5RU-XWBEYOZ-4OCBJ4G-V3XL7FY-2UBTRUO-IWBWWQS";
          #     addresses = "tcp://10.10.0.133:22000";
          # };
          "shirohebi" = {
            id = "V5AOO3B-FXH7JQ6-RBGKBRE-ZJVD5L3-UQ32ZFG-5UWBZI2-W2RFT7O-CANQ5QB";
            addresses = "tcp://10.10.0.12:22000";
          };
        };
        folders = {
          "Zathura" = {
            # Name of folder in Syncthing, also the folder ID
            id = "123-xyz";
            path = "/home/${username}/.local/share/zathura/"; # Which folder to add to Syncthing
            devices = ["yoitsu" "shirohebi"]; # Which devices to share the folder with
            rescanIntervalS = 300;
          };
          # TODO: Uncomment when needed
          # "roms" = {
          #     id = "roms";
          #     path = "/mnt/NAS/ROMs/${platform}/${subdir}";
          #     devices = [ "yoitsu" "steamdeck" ];      # Which devices to share the folder with
          #     rescanIntervalS = 100;
          # };
        };
      };
    };
  };
}
