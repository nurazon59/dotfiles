{ config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/src/github.com/nurazon59/dotfiles";
in
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    darwinFlake = "${dotfiles}/config/nix/nix-darwin";
  };
}
