# netowrking-lab/default.nix
{ inputs, config, lib, pkgs, ... }:
{
    imports = [
        # some other future imprts ...
    ];

    # DEMOS
    services.vsftpd = {
        enable = true;
        localUsers = true;
        writeEnable = true;
        extraConfig = ''
            pasv_min_port=51000
            pasv_max_port=51020
        '';
    };

    security.pam.services = {
        vsftpd.enable = true;
    };

    networking.firewall = {
        allowedTCPPorts = [
            21
        ];
        allowedTCPPortRanges = [
            { from = 51000; to = 51020;}
        ];
    };
}

