{
  description = "My favourite NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Ensures HM uses the same nixpkgs
    };
    # Add zen-browser input here
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # Make zen-browser use the same nixpkgs as the rest of your system
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Add the superfile flake as a new input
    superfile = {
      url = "github:yorukot/superfile";
    };
    # Add Stormy (Weather forecast)
    stormy = {
      url = "github:ashish0kumar/stormy";
    };  
  };

  outputs = { nixpkgs, home-manager, superfile, ... }@inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      myNixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system superfile; }; # Pass inputs and system to modules
        modules = [
          ./nixos/configuration.nix
          {
            nixpkgs.config.allowUnfree = true; # Force it at the flake level
          }
        ];
      };
    };
  };
}
