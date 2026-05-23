{ config, lib, pkgs, ... }:
let
    # --- LOCAL VARIABLES --- #
    discordMic = "~alsa_input.usb-Generic_Blue_Microphones.*";

    # --- DISCORD MIC ROUTING RULE --- #
    discordMicRule = {
        matches = [ { "node.name" = discordMic; } ];
        actions.update-props = {
            "node.autoconnect" = false;
        };
    };
in
{
    services.pipewire.wireplumber.extraConfig."30-discord-mic-routing" = {
        "wireplumber.settings" = {
            "linking.allow-moving-streams" = false;
        };
        "node.rules" = [ discordMicRule ];
    };
}
