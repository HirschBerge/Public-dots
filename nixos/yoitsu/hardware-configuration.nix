# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  boot.supportedFilesystems = ["ntfs"];

  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
  };

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/ef223ecb-2d19-40a7-a458-9ec536d9a9a2";
    fsType = "btrfs";
  };

  fileSystems."/mnt/NAS" = {
    device = "nas-prod-dir.example.com:/mnt/Main Storage/USER_NAME/USER_NAME";
    fsType = "nfs";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ad1f02ff-9d39-478a-a0a7-91887304b160";
    fsType = "btrfs";
    options = ["subvol=@"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/965f3164-484b-404a-9685-514649ec5c41";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FA45-544C";
    fsType = "vfat";
  };

  fileSystems."/mnt/extra" = {
    device = "/dev/disk/by-uuid/4b58a53c-d9bb-457b-992f-c7310b282c2e";
    fsType = "ext4";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/998b6134-3eda-4530-bfdd-20aadf0009ef";}
  ];
  hardware = {
    graphics = {
      # Mesa
      enable = true;
      # Vulkan
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
    };
  };
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp5s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
