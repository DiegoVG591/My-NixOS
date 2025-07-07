# Path: /home/krieg/mysystem/home-manager/home.nix
{ config, pkgs, lib, inputs, superfile, ... }: # Ensure 'lib' is included

{
  # Import your new module here
  imports = [
    ./modules/mic-settings.nix
  ];
  
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
    # discord-ptb
    # --- hyprenviroment pkgs ---
    hyprshot # screnshots
    hyprlock # lookscreen
    hyprpaper # wallpaper
    # --- zen browser ---
    inputs.zen-browser.packages."${pkgs.system}".generic
    pavucontrol
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

  # udiskie: The user-facing auto-mounting daemon for removable media
  services.udiskie = {
    enable = true;
    # any other config you would like to add
  }; 

  home.file.".zshrc.personal" = {
    source = ../zsh/.zshrc.personal;
  };

  # --- ZSH ---
  programs.zsh = {
    enable = true;
    oh-my-zsh.enable = false; # Managing Zsh via .zshrc.personal
    initContent = ''
      # This looks for the symlink that home.file creates at ~/.zshrc.personal
      if [[ -f "$HOME/.zshrc.personal" ]]; then
        source "$HOME/.zshrc.personal"
      fi
    '';
  };

  # --- OBS ---
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };  


  home.stateVersion = "24.05"; # Or "24.11" if you are sure
  programs.home-manager.enable = true;
}
