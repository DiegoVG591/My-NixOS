# Path: /home/krieg/mysystem/home-manager/home.nix
{ config, pkgs, lib, inputs, superfile, ... }: # Ensure 'lib' is included

{
  home.username = "krieg";
  home.homeDirectory = "/home/krieg";

  home.packages = with pkgs; [
    hello
    tree
    rofi-wayland
    brave # browser
    neovim # editor
    thefuck
    tmux
    python314
    plantuml
    zig
    ghostty # main terminal
    inputs.superfile.packages.${pkgs.system}.default # file manager
    # --- hyprenviroment pkgs ---
    hyprshot # screnshots
    hyprlock # lookscreen
    hyprpaper # wallpaper
    # --- zen browser ---
    inputs.zen-browser.packages."${pkgs.system}".generic
    # --- Fonts ---
    font-awesome
    noto-fonts
  ] ++ (
    # Add all Nerd Fonts
    builtins.filter lib.attrsets.isDerivation (lib.attrValues pkgs.nerd-fonts)
  );

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  home.file.".zshrc.personal" = {
  source = ../zsh/.zshrc.personal;
};
  
  programs.zsh = {
    enable = true;
    oh-my-zsh.enable = false; # Managing Zsh via .zshrc.personal
    initContent = ''
      # Source your personal Zsh configuration file from /home/krieg/.zshrc.personal
      if [[ -f "$HOME/mysystem/zsh/.zshrc.personal" ]]; then
        source "$HOME/mysystem/zsh/.zshrc.personal"
      fi
    '';
  };

  home.stateVersion = "24.05"; # Or "24.11" if you are sure
  programs.home-manager.enable = true;
}
