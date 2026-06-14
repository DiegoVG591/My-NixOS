{ config, lib, pkgs, ... }:
{
    # --- STORAGE MANAGEMENT SERVICES --- #
    services.devmon.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    security.polkit.enable = true;
    # --- UPOWER (device battery monitoring) --- #
    services.upower.enable = true;
}
