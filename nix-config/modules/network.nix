{ config, lib, pkgs, ... }:
let
  expressvpn = pkgs.callPackage ../../pkgs/expressvpn.nix {};
in
{
    # --- NETWORK SETTINGS --- #
    networking.hostName = "nixos";
    networking.networkmanager.enable = true;
    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";
    networking.nftables.enable = false;
    networking.firewall.package = pkgs.iptables-legacy;

    # --- FIREWALL SETTINGS --- #
    networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 25565 ]; 
        allowedUDPPorts = [ 24454 ]; 
    };

    # --- EXPRESSVPN CUSTOM SETTINGS ---
    systemd.services.expressvpn = {
        description = "ExpressVPN Daemon";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            ExecStart = "${expressvpn}/bin/expressvpn-daemon";
            Restart = "on-failure";
            RestartSec = 5;
        };
    };
    systemd.tmpfiles.rules = [
        "d /opt/expressvpn/var 0755 root root -"
        "d /opt/expressvpn/etc 0755 root root -"
    ];

    # --- FORCE ETHERNET TO GIGABIT SPEED --- #
    systemd.services.force-gigabit = {
        description = "Force Ethernet enp4s0 to Gigabit";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" "NetworkManager.service" ];
        requires = [ "network-online.target" ];
        path = [ pkgs.ethtool ];
        script = ''
        sleep 10
        ethtool -s enp4s0 speed 1000 duplex full autoneg on
        '';
        serviceConfig = {
            Type = "simple";
            RemainAfterExit = true;
        };
    };
}
