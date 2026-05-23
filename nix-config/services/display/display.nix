# --- GRAPHICS DRIVERS --- #
hardware.graphics.enable = true;

# --- HYPRLAND WINDOW MANAGER --- #
programs.hyprland = {
    enable = true;
    xwayland.enable = true;
};

# --- LOGIN MANAGER --- #
services.greetd = {
    enable = true;
    settings = {
        initial_session = {
            command = "${pkgs.bash}/bin/bash -l -c 'sleep 1; dbus-run-session Hyprland'";
            user = "krieg";
        };
        default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
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
    NIXOS_OZONE_WL = "1";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/krieg/.steam/root/compatibilitytools.d";
    OFX_PLUGIN_PATH = lib.concatStringsSep ":" [];
    XDG_DATA_DIRS = [
        "${pkgs.adwaita-icon-theme}/share"
        "/run/current-system/sw/share"
        "/etc/profiles/per-user/krieg/share"
    ];
    HYPRLAND_LOG_WLR = "1";
};
