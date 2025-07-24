# shell.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # These packages will only be available inside the development shell
  buildInputs = with pkgs; [
    gcc
    pkg-config
    lua
    glfw
    libGL
  ];
}
