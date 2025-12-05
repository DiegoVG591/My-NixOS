# Path: /home/krieg/mysystem/nixos/configuration.nix
{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # Home Manager Integration
  home-manager = {
    extraSpecialArgs = { inherit inputs; }; # This is fine
    users = {
      # Use the simplest import method. This is correct.
      krieg = import ../home-manager/home.nix;
    };
    backupFileExtension = "hm-backup";
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # VirtualBox Guest Additions
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.host.enable = true; # Only if this VM also hosts other VMs

  # Use GPU forom NVIDIA
  # Allow unfree packages, necessary for NVIDIA drivers
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # This is crucial for Wayland compositors like Hyprland
    modesetting.enable = true;
    
    # Recommended for power management on modern GPUs
    powerManagement.enable = true;
    
    # Use the proprietary driver. Set to 'true' only if you have a very new card
    # and want to try the open-source kernel modules. 'dakse' is safer.
    open = false;
    
    # Use the stable driver package from your kernel's package set
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Networking
  networking.hostName = "nixos"; # You can uncomment and set this
  networking.networkmanager.enable = true;

  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # Timezone and Locale
  time.timeZone = "Europe/Madrid";
  #i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        qt6Packages.fcitx5-configtool
    ];
};

environment.variables = {
  GTK_IM_MODULE = "fcitx";
  QT_IM_MODULE = "fcitx";
  XMODIFIERS = "@im=fcitx";
  GLFW_IM_MODULE = "ibus";
};

  # --- Graphics & Display ---
  # For VirtualBox Guest, Mesa drivers are used. NVIDIA settings are not applicable.
  hardware.graphics.enable = true; # Enables OpenGL, Vulkan, VA-API, VDPAU etc. (replaces old hardware.opengl.enable)
  # Hyprland Window Manager
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # For X11 compatibility
    # package = pkgs.hyprland; # Optionally specify a different Hyprland package if needed
  };

  programs.adb.enable = true;

  # Login Manager for Hyprland (using greetd as a lightweight option)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "krieg"; # Your username
      };
    };
    # You can choose different greeters, e.g., tuigreet for a console look
    # extraPackages = [ pkgs.greetd.tuigreet ]; # Add if you want tuigreet
  };

  # If you prefer a graphical login like SDDM:
  # services.sddm = {
  #   enable = true;
  #   wayland.enable = true; # Enable Wayland session support for SDDM
  #   # defaultSession = "hyprland.desktop"; # Or similar, check available .desktop files
  # };

  # USB and external disk automount

  # udisks2: The core service for disk management
  # Even if other services pull it in, explicitly enabling it ensures it's there.
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  # Polkit: For proper privilege handling, allowing non-root users to mount
  security.polkit.enable = true;

  # Environment variables for Wayland sessions
  environment.sessionVariables = {
    # WRL_NO_HARDWARE_CURSORS = "1"; # If your cursor becomes invisible
    NIXOS_OZONE_WL = "1"; # Hint for Electron/Chromium apps to use Wayland
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/krieg/.steam/root/compatibilitytools.d";
    # Davinci resolve plugins
    OFX_PLUGIN_PATH = lib.concatStringsSep ":" [
      # "${pkgs.openfx-misc}"
    ];
    # MOZ_ENABLE_WAYLAND = "1"; # For Firefox
    # QT_QPA_PLATFORM = "wayland"; # For Qt apps
    # SDL_VIDEODRIVER = "wayland";
    # CLUTTER_BACKEND = "wayland";
    # XDG_SESSION_TYPE = "wayland"; # Greetd should set this
  };

  # XDG Desktop Portals (for Flatpak, screen sharing, etc. in Wayland)
  xdg.portal = {
    enable = true;
    wlr.enable = true; # For wlroots-based compositors like Hyprland
    # gtk portal is also useful
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    extraConfig.pipewire."10-global-sample-rate" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
      };
    };
  };
  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  
  # User Definition
  users.users.krieg = {
    isNormalUser = true;
    home = "/home/krieg";
    description = "Krieg GottNMC";
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "pipewire" "adbusers" "wireshark" ]; # Common groups
    shell = pkgs.zsh; # Set Zsh as the default shell
  };

  # Personal pkgs you might not want
  programs.wireshark.enable = true;

  users.users.krieg.packages = with pkgs; [
    discord-ptb
  ];
  # --- steam ---
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    gamescopeSession.enable = true;
  };
  
    # --- Nix-LD (Run unpatched binaries like MCEF/Minecraft Browsers) ---
# --- Nix-LD (Run unpatched binaries like Minecraft Browsers & Unity) ---
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # --- Basics ---
    zlib
    zstd
    stdenv.cc.cc
    curl
    openssl
    attr
    libssh
    bzip2
    libxml2
    acl
    libsodium
    util-linux
    xz
    systemd

    # --- Xorg Libraries (FIXED: Added 'xorg.' prefix where needed) ---
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libXtst
    xorg.libxcb
    xorg.libxshmfence  # <--- This was the cause of your error!
    xorg.libXxf86vm
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXi
    xorg.libSM
    xorg.libICE
    xorg.libXt
    xorg.libXmu
    xorg.libXft

    # --- Graphics & Audio ---
    libGL
    libva
    pipewire
    libdrm
    libgbm
    vulkan-loader
    alsa-lib
    libpulseaudio

    # --- Glitch/Crash Fixes ---
    glib
    gtk2
    gtk3
    gdk-pixbuf
    cairo
    pango
    at-spi2-atk
    at-spi2-core
    dbus
    dbus-glib
    expat
    libxkbcommon 

    # --- Game/Runtime Support ---
    libelf
    nspr
    nss
    cups
    libcap
    SDL2
    libusb1
    ffmpeg
    libudev0-shim
    icu
    libnotify
    
    # --- Image/Audio Formats ---
    libogg
    libvorbis
    flac
    freeglut
    libjpeg
    libpng
    libsamplerate
    libmikmod
    libtheora
    libtiff
    pixman
    speex
    
    # --- Networking/Utils ---
    networkmanager
    libxcrypt
    coreutils
    pciutils
    zenity
    
    # --- Compatibility ---
    fuse
    e2fsprogs
  ];

  programs.gamemode.enable = true;
  hardware.steam-hardware.enable = true;

  # --- OBS ---
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  # --- Davinci resolve ---
  nixpkgs.overlays = [
    (final: prev: {
      # We are creating a modified version of the davinci-resolve package
      davinci-resolve = prev.davinci-resolve.overrideAttrs (oldAttrs: {
        # After installing the package, this hook creates a wrapper script
        postInstall = ''
          makeWrapper $out/bin/resolve $out/bin/davinci-resolve \
            --set QT_QPA_PLATFORM xcb
        '';
      });
    })
  ];

  # System-wide Zsh (makes it available, provides /etc/zshrc)
  programs.zsh.enable = true;
  # Fan argb controler
  services.hardware.openrgb.enable = true;
  boot.kernelModules = [ "i2c-dev" ];

  
  # Nix Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System Packages (keep minimal, prefer Home Manager for user apps)
  environment.systemPackages = with pkgs; [
    vim
    wayland # Core Wayland libraries
    hyprland
    egl-wayland # If not pulled in by other dependencies
    waybar # Status bar for Hyprland
    (waybar.overrideAttrs (oldAttrs: { # If you still need experimental features for Waybar
    mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))
    dunst      # Notification daemon
    libnotify  # For sending notifications
    # swww       # Wallpaper daemon for Wayland (if you use it)
    # rofi-wayland # Application launcher (Wayland-compatible Rofi fork)
    # wofi     # Another common Wayland launcher
    networkmanagerapplet# network manager applet
    # kitty      # Terminal
    ghostty # --- Main terminal ---
    chromium
    wget
    git
    p7zip # 7zip
    home-manager # Useful to have the CLI available
    # --- steam realated pkgs ---
    protonup-ng
    mangohud
    # --- unity for game dev ---
    unityhub
    # --- temporary IDEs
    jetbrains.clion
    # --- not taking ---
    obsidian
    # --- others ---
    davinci-resolve # video editor
    android-tools # for modifing things on Andrid (will use it for installing grapheno)
    # --- Media player open source ---
    vlc
    # --- Image viewer ---
    nsxiv
    # linuxKernel.kernels.linux_zen # Consider if you need a specific kernel, default is usually fine
    # adding partition format types
    exfatprogs # exfat
    jmtpfs # So that I can mount my phones as a file
    # --- Fan arg and speed control ---
    fanctl
    openrgb-with-all-plugins
  ];

  system.stateVersion = "25.05";
}
