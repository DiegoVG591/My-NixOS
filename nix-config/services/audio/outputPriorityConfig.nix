let
    # --- LOCAL VARIABLES --- #
    defaultOutDevice = "alsa_output.usb-Razer_Razer_Barracuda_X-00.analog-stereo";
    ignoredOutDevice = "~alsa_output.usb-Generic_Blue_Microphones.*";

    # --- DEFAULT OUTPUT DEVICE: HEADESET --- #
    defaultDevice = {
        matches = [ { "node.name" = "${defaultOutDevice}"; } ];
        actions.update-props = {
            "priority.driver" = 2000;
            "priority.session" = 2000;
            "device.profile" = "stereo-fallback";
        };
    };

    # --- IGNORED OUTPUT DEVICE: MICROFONE --- #
    ignoredDevice = {
        matches = [ { "node.name" = "${ignoredOutDevice}"; } ];
        actions.update-props = {
            "priority.driver" = 500;
            "priority.session" = 500;
        };
    };
in
    {
    "10-priority-rules" = {
        "monitor.alsa.rules" = [ defaultDevice ignoredDevice ];
    };
}
