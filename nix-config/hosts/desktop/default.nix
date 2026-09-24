# hosts/desktop/default.nix
{ inputs, config, lib, pkgs, ... }:
{
    imports = [
        ../../configuration.nix
        ./hardware-configuration.nix
    ];
}
