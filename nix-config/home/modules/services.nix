{ config, pkgs, lib, inputs, ... }:
let
    # --- VIRTUAL MIC LINK SCRIPT --- #
    virtualMicLinkScript = pkgs.writeShellScript "virtual-mic-link" ''
        for i in $(seq 1 15); do
            if ${pkgs.pipewire}/bin/pw-link VirtualMicSink:monitor_0 VirtualMic:playback_0 2>/dev/null; then
                ${pkgs.pipewire}/bin/pw-link VirtualMicSink:monitor_1 VirtualMic:playback_1
                exit 0
            fi
            sleep 2
        done
    '';
in
{
    # --- GPG AGENT --- #
    services.gpg-agent = {
        enable = true;
        defaultCacheTtl = 1800;
        enableSshSupport = true;
    };

    # --- UDISKIE (removable media automount) --- #
    services.udiskie.enable = true;

    # --- VIRTUAL MIC LINK --- #
    systemd.user.services.virtual-mic-link = {
        Unit.Description = "Link VirtualMicSink to VirtualMic";
        Install.WantedBy = [ "default.target" ];
        Service = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${virtualMicLinkScript}";
        };
    };
}
# TODO: refactor script to reduce nesting levels
