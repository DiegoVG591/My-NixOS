{ config, pkgs, lib, inputs, ... }:
{
    # --- DAVINCI RESOLVE DESKTOP ENTRY --- #
    home.file.".local/share/applications/davinci-resolve.desktop" = {
        source = ../CustomEx/davinci-resolve.desktop;
    };

    # --- ZSH PERSONAL CONFIG --- #
    home.file.".zshrc.personal" = {
        source = ../zsh/.zshrc.personal;
    };
}
