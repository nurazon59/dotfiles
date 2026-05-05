{ pkgs, ... }:
{
  services.sketchybar = {
    enable = true;
    extraPackages = [ pkgs.jq ];
  };

  services.jankyborders = {
    enable = true;
  };
}
