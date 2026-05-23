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

    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
    };
}
