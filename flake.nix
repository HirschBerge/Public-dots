{
  description = "My Favorite NixOS flake!";
  inputs = {
    nixos-boot.url = "github:HirschBerge/nixos-boot";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    home-manager = {
         url = "github:nix-community/home-manager";
         inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/nur";
    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-boot,
    ...
  } @ inputs: let
    inherit (self) outputs;
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        inputs.nur.overlay
        (self: super: {
          warp-terminal = super.warp-terminal.override{
            waylandSupport = true;
          };
        })
      ];

      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
    #  Export Variables
    stateVersion = "23.11"; # TODO: change stateVersion
    username = "USER_NAME"; # TODO: change username
    desktop = "yoitsu"; # TODO: Change Desktop name
    laptop = "shirohebi"; # TODO: change Laptop name
    system = "x86_64-linux"; # TODO: Rarely, change system architecture
    email = "THIS_IS_AN_EMAIL"; # TODO: Change your email for Git and such 
    discord = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTI1NDEyMDE3ODA3NDEyODQ5Ni9jdklWWVlfZURGMXRLcmR1aHJRWGNVZjd5Yi1tWWNSYmFHMmREX09XUkFEVFJ4amtwMW1qamhlTTB4RklkWVV6VWlYRgo"; # TODO: Change/ remove
  in {
    #  NixOS configuration entrypoint
    #  Available through 'nixos-rebuild --flake .# your-hostname'
    nixosConfigurations = {
      ${desktop} = nixpkgs.lib.nixosSystem {
        specialArgs = let
          hostname = "${desktop}";  in {
            inherit
              inputs
              self
              username
              system
              stateVersion
              email
              discord
              hostname;
          };
        #  > Our main nixos configuration file <
        modules = [./nixos/${desktop}/configuration.nix nixos-boot.nixosModules.default];
      };
      ${laptop} = nixpkgs.lib.nixosSystem { 
        specialArgs = let hostname = "${laptop}";  in {
          inherit
            inputs
            self
            username
            system
            stateVersion
            email
            hostname;
        };
        #  > Our main nixos configuration file <
        modules = [./nixos/${laptop}/configuration.nix nixos-boot.nixosModules.default];
      };
    };
    #  Standalone home-manager configuration entrypoint
    #  Available through 'home-manager --flake .# your-username@your-hostname'
    homeConfigurations = {
      "${username}@${desktop}" =  home-manager.lib.homeManagerConfiguration {
        inherit pkgs;#  > Our main home-manager configuration file <
        modules = [./nixos/${desktop}/home.nix];
        extraSpecialArgs =  let hostname = desktop; in {
          inherit
            self
            inputs
            username
            hostname
            system
            stateVersion
            email;
        };
      };
       "${username}@${laptop}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;#  > Our main home-manager configuration file <
        modules = [./nixos/${laptop}/home.nix];
        extraSpecialArgs = let hostname = laptop; in {
          inherit 
            self
            inputs
            username
            hostname
            system
            stateVersion
            email;
            };
       };
    };
  };
}

