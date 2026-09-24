{ config, pkgs, lib, inputs, ... }:
{
    # --- DEFAULT APPLICATION OPENERS --- #
    xdg.mimeApps = {
        enable = true;
        defaultApplications = {
            # --- IMAGES --- #
            "image/jpeg" = [ "nsxiv.desktop" ];
            "image/png"  = [ "nsxiv.desktop" ];
            "image/gif"  = [ "nsxiv.desktop" ];
            "image/webp" = [ "nsxiv.desktop" ];

            # --- VIDEO --- #
            "video/mp4"          = [ "vlc.desktop" ];
            "video/x-matroska"   = [ "vlc.desktop" ];
            "video/webm"         = [ "vlc.desktop" ];
        };
    };
}
