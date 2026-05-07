{ pkgs, ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap";
    };

    taps = [
      "mtgto/macskk"
      "FelixKratz/formulae"
      "nikitabobko/tap"
    ];

    brews = [
      "ical-buddy"
      "sketchybar"
      "borders"
    ];

    casks = [
      "aerospace"
      "alacritty"
      "arc"
      "azookey"
      "claude"
      "clipy"
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
