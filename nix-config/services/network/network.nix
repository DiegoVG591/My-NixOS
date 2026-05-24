networking.hostName = "nixos";
networking.networkmanager.enable = true;
networking.wireless.iwd.enable = true;
networking.networkmanager.wifi.backend = "iwd";

networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 25565 ]; 
    allowedUDPPorts = [ 24454 ]; 
};

services.expressvpn.enable = true;

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

# TODO: Add comments
