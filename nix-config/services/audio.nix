{ config, lib, pkgs, ... }:

let
    myHeadset = "alsa_output.usb-Razer_Razer_Barracuda_X-00.analog-stereo";
in
    {
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber = {
            enable = true;
            extraConfig = {
                "10-priority-rules" = {
                    "monitor.alsa.rules" = [
                        {
                            matches = [ { "node.name" = "${myHeadset}";} ];
                            actions.update-props = {
                                "priority.driver" = 2000;
                                "priority.session" = 2000;
                                "device.profile" = "stereo-fallback"; 
                            };
                        }
                        {
                            matches = [ { "node.name" = "~alsa_output.usb-Generic_Blue_Microphones.*"; } ];
                            actions.update-props = {
                                "priority.driver" = 500;
                                "priority.session" = 500;
                            };
                        }
                    ];
                };
                "20-virtual-mic-link" = {
                    "wireplumber.links" = [
                        {
                            "link.output.node" = "VirtualMicSink";
                            "link.output.port" = "monitor_0";
                            "link.input.node"  = "VirtualMic";
                            "link.input.port"  = "playback_0";
                        }
                        {
                            "link.output.node" = "VirtualMicSink";
                            "link.output.port" = "monitor_1";
                            "link.input.node"  = "VirtualMic";
                            "link.input.port"  = "playback_1";
                        }
                    ];
                };
                "30-discord-mic-routing" = {
                    "wireplumber.settings" = {
                        "linking.allow-moving-streams" = false;
                    };
                    "node.rules" = [
                        {
                            matches = [ { "node.name" = "~alsa_input.usb-Generic_Blue_Microphones.*"; } ];
                            actions = {
                                update-props = {
                                    "node.autoconnect" = false;
                                };
                            };
                        }
                    ];
                };
            };
        };
        extraConfig."10-global-sample-rate" = {
            "context.properties" = {
                "default.clock.rate" = 48000;
            };
        };
    };
}

# TODO:  Use let to devide the code into sections and make it more readable, no more than 3 leves of nesting allowed
# TODO:  Comment the code
