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
    };

    security.pam.services = {
        vsftpd.enable = true;
    };
}

