{ config, lib, pkgs, ... }:
{
    # --- SECURITY SERVICES --- #
    programs.wireshark.enable = true; # network packet analyzer
}
