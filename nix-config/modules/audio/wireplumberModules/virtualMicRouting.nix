{ config, lib, pkgs, ... }:
let
    # --- LEFT CHANNEL --- #
    leftChannel = {
        "link.output.node" = "VirtualMicSink";
        "link.output.port" = "monitor_0";
        "link.input.node"  = "VirtualMic";
        "link.input.port"  = "playback_0";
    };
    # --- RIGHT CHANNEL --- #
    rightChannel = {
        "link.output.node" = "VirtualMicSink";
        "link.output.port" = "monitor_1";
        "link.input.node"  = "VirtualMic";
        "link.input.port"  = "playback_1";
    };
in
{
    services.pipewire.wireplumber.extraConfig."20-virtual-mic-link" = {
        "wireplumber.links" = [ leftChannel rightChannel ];
    };
}
