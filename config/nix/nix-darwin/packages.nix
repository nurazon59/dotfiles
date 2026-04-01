{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    tmux
    neovim
    nixd
    nixfmt
    btop
    lua
    lima
    postgresql_18
    qemu
    sheldon
    switchaudio-osx
  ];
}
