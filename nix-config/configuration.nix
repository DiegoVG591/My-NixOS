{ inputs, config, lib, pkgs, ... }:
{
    imports = [
        ./hardware-configuration.nix
        inputs.home-manager.nixosModules.home-manager
        # --- SYSTEM MODULES --- #
        ./modules/audio/audio.nix
        ./modules/boot.nix
        ./modules/display.nix
        ./modules/gaming.nix
        ./modules/nix-ld.nix
        ./modules/network.nix
        ./modules/security.nix
        ./modules/storage.nix
        ./modules/system.nix
    ];
    # --- HOME MANAGER INTEGRATION --- #
    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        users.krieg = import ./home/home.nix;
        backupFileExtension = "hm-backup";
    };
}
