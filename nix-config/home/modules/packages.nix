{ config, pkgs, lib, inputs, ... }:
let
    # --- NVIM UNITY INTEGRATION SCRIPT --- #
    nvimunity = pkgs.writeShellScriptBin "nvimunity" ''
        #!/bin/sh
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
        '';
in
    {
    home.packages = with pkgs; [
        # --- UTILITIES --- #
        hello
        tree
        unzip
        pay-respects

        # --- TERMINAL --- #
        tmux

        # --- BROWSER --- #
        brave

        # --- LANGUAGES & DEVELOPMENT --- #
        lua
        luarocks
        selene          # Lua linter
        python314
        zig
        go
        nodejs          # provides npm
        dotnet-sdk
        jdk
        clang-tools     # C/C++ language server (clangd)
        cmake

        # --- PERSONAL IDE --- #
        neovim
        gcc
        tree-sitter

        # --- IMAGE EDITORS --- #
        gimp3

        # --- MEDIA --- #
        ffmpeg-full
        yt-dlp
        pulseaudio

        # --- CONTENT CREATION --- #
        davinci-resolve  # video editor

        # --- CYBERSECURITY --- #
        wireshark
        nmap
        nginx

        # --- GAMING --- #
        prismlauncher    # Minecraft launcher
        heroic           # Epic/GOG game launcher

        # --- HYPRLAND ENVIRONMENT --- #
        hyprshot         # screenshots
        hyprlock         # lockscreen
        hyprpaper        # wallpaper

        # --- AUDIO --- #
        pavucontrol
        ydotool          # input simulation

        # --- ROFI --- #
        rofi             # application launcher

        # --- WEATHER --- #
        inputs.stormy.packages.${pkgs.stdenv.hostPlatform.system}.stormy

        # --- NVIM UNITY INTEGRATION --- #
        nvimunity
    ];
}
