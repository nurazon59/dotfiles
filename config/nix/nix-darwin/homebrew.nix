{ pkgs, ... }:
{
  homebrew = {
    enable = true;

    taps = [
      "FelixKratz/formulae"
      "nikitabobko/tap"
      "k1LoW/tap"
    ];

    brews = [
      "ical-buddy"
      "sketchybar"
      "borders"
      "mo"
      "sandvault"
    ];

    casks = [
      "1password"
      "aerospace"
      "alacritty"
      "arc"
      "azookey"
      "claude"
      "clipy"
      "datagrip"
      "espanso"
      "finetune"
      "font-sf-pro"
      "input-source-pro"
      "karabiner-elements"
      "linearmouse"
      "monitorcontrol"
      "notunes"
      "sf-symbols"
      "shottr"
      "sol"
    ];
  };
}
