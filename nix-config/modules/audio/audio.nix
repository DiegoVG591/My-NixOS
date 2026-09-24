{ config, lib, pkgs, ... }:
{
    imports = [
        # --- PIPEWIRE MODULES --- #
        ./pipewireModules/globalSampleRate.nix
        # --- WIREPLUMBER MODULES --- #
        ./wireplumberModules/outputPriorityConfig.nix
        ./wireplumberModules/virtualMicRouting.nix
        ./wireplumberModules/discordMicRouting.nix
    ];

    # --- BLUETOOTH --- #
    hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
            General.FastConnectable = true;
            Policy.AutoEnable = true;
        };
    };
    environment.etc."bluetooth/input.conf".text = lib.mkForce ''
    [General]
    ClassicBondedOnly=false
    '';

    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
    };
}
