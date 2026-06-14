{ config, lib, pkgs, ... }:
{
    # --- GLOBAL SAMPLE RATE --- #
    services.pipewire.extraConfig.pipewire."10-global-sample-rate" = {
        "context.properties" = {
            "default.clock.rate" = 48000;
        };
    };
}
