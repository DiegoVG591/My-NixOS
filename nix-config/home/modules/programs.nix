{ config, pkgs, lib, inputs, ... }:
{
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

    # --- SET ZEN AS DEFAULT BROWSER --- #
    xdg.mimeApps = {
        enable = true;
        defaultApplications = {
            "text/html"             = "zen-beta.desktop";
            "x-scheme-handler/http" = "zen-beta.desktop";
            "x-scheme-handler/https" = "zen-beta.desktop";
            "x-scheme-handler/about" = "zen-beta.desktop";
            "x-scheme-handler/unknown" = "zen-beta.desktop";
        };
    };

    # --- HOME MANAGER --- #
    programs.home-manager.enable = true;
}
