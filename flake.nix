{
  description = "My Favorite NixOS flake!";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    home-manager = {
         url = "github:nix-community/home-manager";
         inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/nur";
  };


  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    stateVersion = "23.05";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        inputs.nur.overlay
      ];
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
    username = "YOUR_USER"; #TODO change username
    desktop = "yoitsu"; #TODO Change Desktop name
    laptop = "shirohebi"; #TODO change Laptop name
    system = "x86_64-linux"; #TODO Rarely, change system architecture
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      ${desktop} = nixpkgs.lib.nixosSystem {
        specialArgs = let #TODO Change actual hostname
        hostname = "yoitsu"; in {inherit inputs username self system stateVersion hostname;};
        # > Our main nixos configuration file <
        modules = [./nixos/${desktop}/configuration.nix];
      };
      ${laptop} = nixpkgs.lib.nixosSystem { #TODO Change actual hostname
        specialArgs = let hostname = "shirohebi"; in {inherit inputs username self system stateVersion hostname;};
        # > Our main nixos configuration file <
        modules = [./nixos/${laptop}/configuration.nix];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "${username}@${desktop}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;# > Our main home-manager configuration file <
        modules = [./nixos/${desktop}/home.nix];
        extraSpecialArgs = let hostname = desktop; in {inherit username hostname self system stateVersion inputs;};
      };
       "${username}@${laptop}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;# > Our main home-manager configuration file <
        modules = [./nixos/${laptop}/home.nix];
        extraSpecialArgs = let hostname = laptop; in {inherit username hostname self system stateVersion inputs;};
      };
    };
  };
}

