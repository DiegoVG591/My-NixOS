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

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
    
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Networking
  networking.hostName = "nixos"; # You can uncomment and set this
  networking.networkmanager.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 81 443 20 21 990 ];
    allowedTCPPortRanges = [ 
        { from = 5000; to = 10000; }
    ];
  };

  services.httpd.enable = true;
  services.httpd.adminAddr = "webmaster@example.org";
  services.httpd.enablePHP = true; # oof... not a great idea in my opinion

  services.httpd.virtualHosts."example.org" = {
    documentRoot = "/var/www/example.org";
    # want ssl + a let's encrypt certificate? add `forceSSL = true;` right here
  };

  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  services.nginx.package = pkgs.nginxStable.override { openssl = pkgs.libressl; };
  # FPT (File transfer protocol)
  services.vsftpd = {
    enable = true;
    
    # === Basic Configuration ===
    # anonymousEnable = false;    # Disable anonymous login
    # localEnable = true;         # Allow local users to log in
    # writeEnable = true;         # Allow file uploads/changes
    # localUmask = "0002";        # Set file permissions for new files (664) and folders (775)
    # 
    # === Passive Mode Port Range ===
    # pasvEnable = true;
    # pasvMinPort = 5000;
    # pasvMaxPort = 10000;
    # 
    # === Directory and Chroot (Jail) Settings ===
    # localRoot = "/ftp";                 # Set a common root directory for all users
    # chrootLocalUser = true;             # Restrict users to their home/root directory
    # allowWriteableChroot = true;        # A necessary security setting for modern vsftpd
    # chrootListEnable = true;            # Enable the list of users who are NOT jailed
    # chrootListFile = "/etc/vsftpd.chroot_list"; # Path to that list
  
    # === SSL/TLS Configuration ===
    # sslEnable = true;                   # Enable SSL/TLS
    # NOTE: We will generate this vsftpd.pem file in the next section.
    # This path assumes you place it within your Nix config directory.
    # rsaCertFile = "/home/krieg/mysystem/certs/vsftpd.pem";
    # rsaPrivateKeyFile = "/home/krieg/mysystem/certs/vsftpd.pem";
    # allowAnonSsl = false;               # Don't allow anonymous users over SSL
    # forceLocalDataSsl = true;           # Force data transfer over SSL
    # forceLocalLoginsSsl = true;         # Force logins over SSL
    # 
    # --- Recommended SSL/TLS Protocols and Ciphers ---
    # sslTlsv1 = true;
    # sslSslv2 = false;
    # sslSslv3 = false;
    # requireSslReuse = false;
    # sslCiphers = "HIGH";
  };

  # Create the /ftp directory with correct permissions
  systemd.tmpfiles.rules = [
    "d /ftp 0755 root root -"
  ];
  
  # Create the chroot list and add your admin user to it
  # This user will NOT be jailed in the FTP directory.
  environment.etc."vsftpd.chroot_list".text = ''
    # Users listed in this file will NOT be chrooted.
    krieg
  '';

  # Timezone and Locale
time.timeZone = "Europe/Madrid";
#i18n.defaultLocale = "en_US.UTF-8";
i18n.inputMethod = {
  enabled = "fcitx5";
  fcitx5.addons = with pkgs; [
    fcitx5-mozc
    fcitx5-gtk
    fcitx5-configtool
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
  users.users.ftpuser = {
    isNormalUser = true;
    description = "User for FTP access";
        shell = pkgs.shadow + "/bin/nologin"; # This prevents interactive logins
  };

  # Blockd the user in the SSHD config
  #services.openssh = {
  #  enable = true;
  #  settings.DenyUsers = [ "ftpuser" ];
  #};

  users.users.krieg = {
    isNormalUser = true;
    home = "/home/krieg";
    description = "Krieg GottNMC";
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "pipewire" "adbusers" "wireshark" ]; # Common groups
    shell = pkgs.zsh; # Set Zsh as the default shell
  };
  
  # --- wireshark ---
  programs.wireshark.enable = true;

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
    protonup
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
    # linuxKernel.kernels.linux_zen # Consider if you need a specific kernel, default is usually fine
    # adding partition format types
    exfatprogs # exfat
    jmtpfs # So that I can mount my phones as a file
  ];

  system.stateVersion = "25.05";
}
