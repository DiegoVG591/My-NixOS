# Path: /home/krieg/mysystem/home-manager/home.nix
{ config, pkgs, lib, inputs, superfile, ... }: # Ensure 'lib' is included

{
  home.username = "krieg";
  home.homeDirectory = "/home/krieg";

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
  
  systemd.user.services."create-virtual-mic" = {
    Unit = {
      Description = "Create a PipeWire loopback device for OBS";
      # We now depend on the native pipewire service
      After = [ "pipewire.service" ];
    };
  
    Service = {
      # This uses PipeWire's native tool, pw-cli, to load the loopback module.
      # This is the most direct and reliable method.
      ExecStart = ''
        ${pkgs.pipewire}/bin/pw-cli load-module libpipewire-module-loopback \
        node.description="OBS-Virtual-Audio" \
        capture.props={node.description="Virtual-Mic-Source-(from-OBS)"} \
        playback.props={node.description="Virtual-Mic-Sink-(to-OBS)"}
      '';
    };
  
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
  
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
    # --- Cybersecurity pkgs --
    wirshark
    # --- Minecraft launcher ---
    prismlauncher
    inputs.superfile.packages.${pkgs.system}.default # file manager
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
    # --- zen browser ---
    inputs.zen-browser.packages."${pkgs.system}".generic
    pavucontrol
    # --- Fonts ---
    font-awesome
    noto-fonts
    monocraft
    rictydiminished-with-firacode
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
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };  


  home.stateVersion = "24.05"; # Or "24.11" if you are sure
  programs.home-manager.enable = true;
}
