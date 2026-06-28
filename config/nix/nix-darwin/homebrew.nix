{ pkgs, user, ... }:
let
  commonCasks = [
    "1password"
    "aerospace"
    "arc"
    "azookey"
    "claude"
    "clipy"
    "espanso"
    "finetune"
    "font-hackgen-nerd"
    "font-sf-pro"
    "input-source-pro"
    "karabiner-elements"
    "linearmouse"
    "monitorcontrol"
    "notunes"
    "session-manager-plugin"
    "sf-symbols"
    "orbstack"
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
    ];

    brews = [
      "ical-buddy"
      "sketchybar"
    ];

    casks = casks;
  };
}
