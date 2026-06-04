{ inputs, config, lib, pkgs, ... }:
{
    imports = [
        ./hardware-configuration.nix
        inputs.home-manager.nixosModules.home-manager
        # --- SYSTEM MODULES --- #
        ./services/audio/audio.nix
        ./services/boot/boot.nix
        ./services/display/display.nix
        ./services/gaming/gaming.nix
        ./services/lib/nix-ld.nix
        ./services/network/network.nix
        ./services/security/security.nix
        ./services/storage/storage.nix
        ./services/system/system.nix
    ];

    # --- HOME MANAGER INTEGRATION --- #
    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        users.krieg = import ../home-manager/home.nix;
        backupFileExtension = "hm-backup";
    };
}
