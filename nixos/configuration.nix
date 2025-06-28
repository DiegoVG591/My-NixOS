# Path: /home/krieg/mysystem/nixos/configuration.nix
{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # Home Manager Integration
  home-manager = {
    extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to Home Manager modules
    users = {
      krieg = import ../home-manager/home.nix; # Corrected path
    };
    backupFileExtension = "hm-backup";
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # VirtualBox Guest Additions
  virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.host.enable = true; # Only if this VM also hosts other VMs

  # Use GPU forom NVIDIA
  # Allow unfree packages, necessary for NVIDIA drivers
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "vboxvideo" ];
  hardware.nvidia.powerManagement.enable = true; # Recommended for NVIDIA
  hardware.nvidia.open = false; # Set to true for open-source drivers (if supported by your card)

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


  # Environment variables for Wayland sessions
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Hint for Electron/Chromium apps to use Wayland
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

  # User Definition
  users.users.krieg = {
    isNormalUser = true;
    home = "/home/krieg";
    description = "Krieg GottNMC";
    extraGroups = [ "wheel" "video" "audio" "networkmanager" ]; # Common groups
    shell = pkgs.zsh; # Set Zsh as the default shell
  };

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
    swww       # Wallpaper daemon for Wayland (if you use it)
    # rofi-wayland # Application launcher (Wayland-compatible Rofi fork)
    # wofi     # Another common Wayland launcher
    networkmanagerapplet# network manager applet
    kitty      # Terminal
    chromium
    picom
    git
    home-manager # Useful to have the CLI available
    # linuxKernel.kernels.linux_zen # Consider if you need a specific kernel, default is usually fine
  ];

  system.stateVersion = "24.11"; # Or "24.05" if that was your original install version
}
