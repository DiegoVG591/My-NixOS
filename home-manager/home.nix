# Path: /home/krieg/mysystem/home-manager/home.nix
{ config, pkgs, lib, inputs, ... }: # Ensure 'lib' is included

{
  home.username = "krieg";
  home.homeDirectory = "/home/krieg";

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    hello
    tree
    rofi
    brave # browser
    lua
    luarocks
    #
    pay-respects
    tmux
    # --- Image editors ---
    gimp3
    # --- media download & conversion ---
    ffmpeg-full
    yt-dlp
    # --- languages --
    selene # for linting
    python314
    plantuml
    zig
    go
    unzip
    nodejs # This provides npm
    dotnet-sdk
    jdk
    # Content creation stuff
    davinci-resolve # Video Editor
    # --- Cybersecurity pkgs --
    wireshark
    nmap
    nginx
    # --- Minecraft launcher ---
    prismlauncher
    # --- Stormy (Weather forecast)
    inputs.stormy.packages.${pkgs.stdenv.hostPlatform.system}.stormy
    #
    pulseaudio
    # For C# Language Server
    dotnet-sdk
    # For C/C++ Language Server (clangd) and build tools
    clang-tools
    cmake
    # --- hyprenviroment pkgs ---
    hyprshot # screnshots
    hyprlock # lookscreen
    hyprpaper # wallpaper
    # --- game launchers ---
    heroic
    pavucontrol
    # --- Fonts ---
        # font-awesome
        # noto-fonts
        # monocraft
        # rictydiminished-with-firacode
    # --- INSERT NVIM UNITY HERE ---
    (writeShellScriptBin "nvimunity" ''
       #!/bin/sh
       # We add the required tools to the path specifically for this script
       export PATH="${pkgs.jq}/bin:${pkgs.xdotool}/bin:$PATH"

       CONFIG_DIR="$HOME/.config/nvim-unity"
       CONFIG_FILE="$CONFIG_DIR/config.json"
       NVIM_PATH="nvim"
       SOCKET="$HOME/.cache/nvimunity.sock"
       mkdir -p "$CONFIG_DIR"
        
       if [ ! -f "$CONFIG_FILE" ]; then
         echo '{"last_project": ""}' > "$CONFIG_FILE"
       fi
        
       LAST_PROJECT=$(jq -r '.last_project' "$CONFIG_FILE")
        
       FILE="$1"
       # Note the double single-quotes ''${...} for Nix escaping
       LINE="''${2:-1}"
        
       if ! [[ "$LINE" =~ ^[1-9][0-9]*$ ]]; then
         LINE="1"
       fi
        
       SHIFT_PRESSED=false
       if command -v xdotool >/dev/null; then
         xdotool keydown Shift_L keyup Shift_L >/dev/null 2>&1 && SHIFT_PRESSED=true
       fi
        
       if [ "$SHIFT_PRESSED" = true ] && [ -n "$LAST_PROJECT" ]; then
         CMD="$NVIM_PATH --listen $SOCKET \"+$LINE\" \"+cd \"$LAST_PROJECT\"\" \"$FILE\""
       else
         CMD="$NVIM_PATH --listen $SOCKET \"+$LINE\" \"$FILE\""
       fi
        
       eval "$CMD"
    '')
  ];
        # ] ++ (
        #   # Add all Nerd Fonts
        #   builtins.filter lib.attrsets.isDerivation (lib.attrValues pkgs.nerd-fonts)
        # );

        # fonts.fontconfig.enable = true;

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

  # --- File pointers ---

  # davinci-resolve
  home.file.".local/share/applications/davinci-resolve.desktop" = {
    source = ../CustomEx/davinci-resolve.desktop;
  };

  # zsh
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

  # --- Zen browser ---
  imports = [
    ./modules/obs-virtual-mic.nix
    inputs.zen-browser.homeModules.beta
    # or inputs.zen-browser.homeModules.twilight
    # or inputs.zen-browser.homeModules.twilight-official
  ];

  programs.zen-browser.enable = true;

  # --- Neovim Configuration ---
  # This is now its own separate block, which is the correct syntax.
  programs.neovim = {
    enable = true;
    # This makes the C compiler and tree-sitter CLI available to Neovim
    # so it can successfully compile the parsers.
    extraPackages = with pkgs; [
      gcc
      tree-sitter
    ];
  };

  # --- OBS ---
  programs.obs-studio = {
    enable = true;
    # Force OBS to build with Nvidia CUDA/NVENC support
    package = pkgs.obs-studio.override { cudaSupport = true; };
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };  

  # --- DEFAULT OPENERS ---
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = [ "nsxiv.desktop" ];
      "image/png" = [ "nsxiv.desktop" ];
      "image/gif" = [ "nsxiv.desktop" ];
      "image/webp" = [ "nsxiv.desktop" ];
    };
  };

  home.stateVersion = "24.05"; # Or "24.11" if you are sure
  programs.home-manager.enable = true;
}
