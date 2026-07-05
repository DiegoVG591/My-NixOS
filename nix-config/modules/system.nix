{ config, lib, pkgs, ... }:
{
    # --- USER SETTINGS --- #
    users.users.krieg = {
        isNormalUser = true;
        home = "/home/krieg";
        description = "Krieg GottNMC";
        extraGroups = [ 
            "wheel"          # sudo access
            "video"          # GPU access
            "audio"          # audio devices
            "networkmanager" # manage network connections
            "pipewire"       # pipewire audio
            "adbusers"       # Android debugging
            "wireshark"      # packet capture without root
            "input"          # input devices (ydotool)
        ];
        shell = pkgs.zsh;
    };

    # --- TIME ZONE SETTING  --- #
    time.timeZone = "Europe/Madrid";

    # --- JAPANESE INPUT METHOD --- #
    i18n.inputMethod = {
        type = "fcitx5";
        enable = true;
        fcitx5.addons = with pkgs; [
            fcitx5-mozc                    # Japanese input
            fcitx5-gtk                     # GTK im module for X11/XWayland GTK apps
            qt6Packages.fcitx5-configtool  # GUI config tool
        ];
    };

    # --- GENERAL VARIABLES --- #
    environment.variables = {
        # --- INPUT METHOD --- #
        XMODIFIERS = "@im=fcitx";
        GTK_IM_MODULE = lib.mkForce "";
        QT_IM_MODULE = "fcitx";
        QT_IM_MODULES = "wayland;fcitx";

        # --- DEFAULT APPLICATIONS --- #
        DEFAULT_BROWSER = "zen";
        BROWSER = "zen";
        AUDIO_PLAYER = "mpv";
        TERMINAL = "ghostty";
        EDITOR = "nvim";

        # --- WAYLAND --- #
        MOZ_ENABLE_WAYLAND = "1";

        # --- YDOTOOL --- #
        YDOTOOL_SOCKET = "/run/ydotoold.socket";
    };

    # --- ZSH (the main shell I use) --- #
    programs.zsh.enable = true;

    # --- THIRD PARTY APP SUPPORT --- #
    services.flatpak.enable = true;

    # --- ENABLE FLAKE (eventually will not be needed)  --- #
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # --- SYSTEM WITH PKGS --- #
    environment.systemPackages = with pkgs; [
        # --- WAYLAND / DISPLAY --- #
        wayland
        egl-wayland
        hyprland
        waybar
        (waybar.overrideAttrs (oldAttrs: {
            mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
        }))
        dunst           # notification daemon
        libnotify       # send notifications
        ghostty         # main terminal

        # --- NETWORK --- #
        networkmanagerapplet  # network manager tray applet
        wget
        chromium

        # --- FILE MANAGEMENT --- #
        superfile        # terminal file manager
        p7zip            # 7zip archive tool
        jmtpfs           # mount Android phones as files
        exfatprogs       # exFAT filesystem support

        # --- AUDIO / VIDEO --- #
        droidcam         # use phone as webcam
        vlc              # media player
        mpv              # lightweight media player (used by anki)
        pavucontrol      # PipeWire/PulseAudio volume control
        playerctl        # media player controller

        # --- GAMING --- #
        protonup-ng      # manage Proton versions
        mangohud         # performance overlay for games
        wineWow64Packages.waylandFull  # Windows compatibility layer

        # --- DEVELOPMENT --- #
        git
        vim
        jetbrains.clion  # C/C++ IDE (temporary)
        unityhub         # Unity game engine
        android-tools    # ADB for Android devices

        # --- HARDWARE CONTROL --- #
        bluez  # bluetooth CLI tools (bluetoothctl)
        fanctl           # fan speed control
        openrgb-with-all-plugins  # RGB control

        # --- PRODUCTIVITY --- #
        obsidian         # note taking
        anki             # flashcard learning
        home-manager     # manage user config via CLI

        # --- SECURITY --- #
        (callPackage ../../pkgs/expressvpn.nix {})       # VPN client

        # --- SYSTEM UTILS --- #
        openssl
        pv               # pipe viewer (progress for pipes)
        bc               # calculator (used by autoclicker scripts)
        flatpak          # sandboxed app runtime

        # --- IMAGE VIEWER --- #
        nsxiv            # minimalist image viewer
    ];

    # --- HARDWARE SERVICES --- #
    services.hardware.openrgb.enable = true; # RGB control daemon + udev rules

    # --- FONTS --- #
    fonts.fontDir.enable = true;
    fonts.packages = with pkgs; [
        rictydiminished-with-firacode  # Japanese programming font
        noto-fonts                      # universal Unicode coverage
        monocraft                       # Minecraft style monospace font
        font-awesome                    # icon font
    ] ++ (
            builtins.filter lib.attrsets.isDerivation (lib.attrValues pkgs.nerd-fonts)
            # all Nerd Fonts for terminal icons
        );

    # --- NIXOS STATE VERSION  --- #
    system.stateVersion = "25.05";

    # --- DEMONS FOR E/S SIMULATION (auto clicker) --- #
    systemd.services.ydotoold = {
        description = "ydotool daemon";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            ExecStart = "${pkgs.ydotool}/bin/ydotoold --socket-path=/run/ydotoold.socket --socket-perm=0660";
            RuntimeDirectory = "ydotoold";
            User = "root";
            Group = "input"; # needs input group to simulate keypresses
            Restart = "always";
        };
    };
}
