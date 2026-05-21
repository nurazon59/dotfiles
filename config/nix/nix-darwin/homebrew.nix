{ pkgs, user, ... }:
let
  commonCasks = [
    "1password"
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
    "session-manager-plugin"
    "sf-symbols"
    "shottr"
    "sol"
  ];

  workCasks = [
    "datagrip"
  ];

  personalCasks = [
    "discord"
    "whatsapp"
  ];

  casks = commonCasks ++ (if user == "koshiishi" then workCasks else personalCasks);
in
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
      "mo"
    ];

    casks = casks;
  };
}
