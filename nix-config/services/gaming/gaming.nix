{ config, lib, pkgs, ... }:
{
    # --- STEAM FIREWALL SETTINGS --- #
    programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        gamescopeSession.enable = true;
    };

    # --- GAMING TOOLS --- #
    programs.gamemode.enable = true; # performance optimizer for games
    hardware.steam-hardware.enable = true; # udev rules for Steam controllers/devices
}
