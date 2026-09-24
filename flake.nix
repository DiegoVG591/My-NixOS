{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stormy = {
      url = "github:ashish0kumar/stormy";
    };
    nvim-config = {
      url = "github:DiegoVG591/nvim";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux"; # both hosts are x86_64-linux, shared here
  in
  {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };
        modules = [
          ./nix-config/hosts/desktop/default.nix
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
      laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };
        modules = [
          ./nix-config/hosts/laptop/default.nix
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };
  };
}
