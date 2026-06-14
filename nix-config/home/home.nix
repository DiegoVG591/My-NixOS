{ config, pkgs, lib, inputs, ... }:
{
    imports = [
        # --- HOME MODULES --- #
        ./modules/packages.nix
        ./modules/programs.nix
        ./modules/services.nix
        ./modules/files.nix
        ./modules/display.nix
        # --- EXISTING MODULES --- #
        ./modules/obs-virtual-mic.nix
        ./modules/meeting-reminders.nix
        # --- EXTERNAL MODULES --- #
        inputs.zen-browser.homeModules.beta
    ];

    # --- HOME SETTINGS --- #
    home.username = "krieg";
    home.homeDirectory = "/home/krieg";
    home.stateVersion = "24.05";

    # --- SESSION --- #
    home.sessionPath = [ "$HOME/.local/bin" ];
    home.sessionVariables = {
        EDITOR = "nvim";
    };

    # --- ALLOW PROPRIETARY PACKAGES --- #
    nixpkgs.config.allowUnfree = true;
}
