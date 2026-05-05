{ pkgs, ... }:
{
  services.sketchybar = {
    enable = true;
    extraPackages = [
      pkgs.jq
      pkgs.aerospace
    ];
  };

  services.jankyborders = {
    enable = true;
  };
}
