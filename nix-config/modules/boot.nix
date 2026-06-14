{ config, lib, pkgs, ... }:
{
    # === BOOTLOADER ===
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # --- ALLOW PROPRIETARY PACKAGES (required for Nvidia) ---
    nixpkgs.config.allowUnfree = true;

    # --- ENVIDIA SETUP SETINGS ---
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = false;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # --- KERNEL PARAMETERS --- #
    boot.kernelParams = [ "pcie_aspm=off" ]; # fixes Nvidia PCIe stability issues
    boot.kernelPackages = pkgs.linuxPackages_latest; # always use latest kernel

    # --- EXTRA KERNEL MODULES --- #
    boot.extraModulePackages = with config.boot.kernelPackages; [
        (callPackage ../../pkgs/r8126.nix { kernel = config.boot.kernelPackages.kernel; }) # RTL8126 5GbE NIC driver
        v4l2loopback # virtual camera for OBS/DroidCam
    ];
    boot.blacklistedKernelModules = [ "r8169" ]; # blacklist old NIC driver conflicting with r8126
    boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1 # OBS virtual camera config
    '';

    # --- KERNEL MODULES --- #
    boot.kernelModules = [
        "i2c-dev"      # required for OpenRGB
        "v4l2loopback" # virtual camera
        "snd-aloop"    # audio loopback for virtual mic
    ];
}
