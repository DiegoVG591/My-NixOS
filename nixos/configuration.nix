# Path: /home/krieg/mysystem/nixos/configuration.nix
{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # Home Manager Integration
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
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

  # Timezone and Locale
  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us"; # Example, set your preferred keymap

  # --- Graphics & Display ---
  # For VirtualBox Guest, Mesa drivers are used. NVIDIA settings are not applicable.
  hardware.graphics.enable = true; # Enables OpenGL, Vulkan, VA-API, VDPAU etc. (replaces old hardware.opengl.enable)
  # Hyprland Window Manager
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # For X11 compatibility
    # package = pkgs.hyprland; # Optionally specify a different Hyprland package if needed
  };

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
    wireplumber.enable = true; # It's good practice to keep this explicit
    # Setting sample rate to 48kHz to ensure noise supresor sounds good
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
    # This settings block is correct and works.
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
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "pipewire" ]; # Common groups
    shell = pkgs.zsh; # Set Zsh as the default shell
  };
  # Personal pkgs you might not want
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
  
  programs.gamemode.enable = true;
  hardware.steam-hardware.enable = true;

  # --- OBS ---
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  
  # System-wide Zsh (makes it available, provides /etc/zshrc)
  programs.zsh.enable = true;
  
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
    chromium
    wget
    git
    p7zip
    home-manager # Useful to have the CLI available
    # --- steam realated pkgs ---
    protonup
    mangohud
    alsa-utils
    # linuxKernel.kernels.linux_zen # Consider if you need a specific kernel, default is usually fine
    # adding partition format types
    exfatprogs # exfat
  ];

  system.stateVersion = "25.05";
}
