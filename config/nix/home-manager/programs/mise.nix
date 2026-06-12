{ config, pkgs, ... }:
{
  programs.mise = {
    enable = true;
    package = pkgs.mise;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/share/mise/shims"
  ];
}
