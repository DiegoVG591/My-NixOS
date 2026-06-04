{ config, lib, pkgs, ... }:
{
    # --- GRAPHICS DRIVERS --- #
    hardware.graphics.enable = true;

    # --- HYPRLAND WINDOW MANAGER --- #
    programs.hyprland = {
        enable = true;
        xwayland.enable = true; # Make it so x11 software can run in wayland
    };

    # --- LOGIN MANAGER --- #
    services.greetd = {
        enable = true;
        settings = { 
            initial_session = {
                command = "${pkgs.bash}/bin/bash -l -c 'sleep 1; dbus-run-session Hyprland'"; # Start D-Bus session before Hyprland (required for inter-app communication)
                user = "krieg";
            }; 
            default_session = {
                command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # Fallback login screen: shows TUI greeter with clock before launching Hyprland
                user = "krieg";
            };
        };
    };

    # --- XDG PORTALS --- #
    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config = {
            common = {
                default = [ "hyprland" "gtk" ];
            };
        };
    };

    # --- SESSION ENVIRONMENT VARIABLES --- #
    environment.sessionVariables = {
        NIXOS_OZONE_WL = "1"; # Hint Electron/Chromium apps to use Wayland
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/krieg/.steam/root/compatibilitytools.d"; # Path for manually installed Proton versions (ProtonUp)
        OFX_PLUGIN_PATH = lib.concatStringsSep ":" []; # OFX video editor plugins path (empty - placeholder for future plugins)
        XDG_DATA_DIRS = [ # Where apps look for icons, themes and desktop files
            "${pkgs.adwaita-icon-theme}/share"
            "/run/current-system/sw/share"
            "/etc/profiles/per-user/krieg/share"
        ];
        # HYPRLAND_LOG_WLR = "1"; # For debugin
    };
}
