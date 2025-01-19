{...}: {
  programs.hyprland = {
    withUWSM = false;
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint Electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1"; # for firefox to run on wayland
    MOZ_WEBRENDER = "1";
  };
}
