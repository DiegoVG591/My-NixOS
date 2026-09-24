# hosts/laptop/default.nix
{ inputs, config, lib, pkgs, ... }:
{
    imports = [
        ../../configuration.nix
        ./hardware-configuration.nix
        ./hybrid-graphics.nix
    ];
}
