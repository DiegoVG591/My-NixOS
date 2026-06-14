{ config, pkgs, lib, inputs, ... }:
{
    # --- NEOVIM --- #
    programs.neovim = {
        enable = true;
        extraPackages = with pkgs; [
            gcc
            tree-sitter
        ];
    };

    # --- ZSH --- #
    programs.zsh = {
        enable = true;
        oh-my-zsh.enable = false;
        initContent = ''
            if [[ -f "$HOME/.zshrc.personal" ]]; then
                source "$HOME/.zshrc.personal"
            fi
        '';
    };

    # --- OBS --- #
    programs.obs-studio = {
        enable = true;
        package = pkgs.obs-studio.override { cudaSupport = true; };
        plugins = with pkgs.obs-studio-plugins; [
            wlrobs
            obs-backgroundremoval
            obs-pipewire-audio-capture
        ];
    };

    # --- ZEN BROWSER --- #
    programs.zen-browser.enable = true;

    # --- HOME MANAGER --- #
    programs.home-manager.enable = true;
}
