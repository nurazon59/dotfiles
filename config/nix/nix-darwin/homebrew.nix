{ pkgs, user, ... }:
let
  commonCasks = [
    "1password"
    "aerospace"
    "arc"
    "azookey"
    "chatgpt"
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
    "opendisplay"
    "session-manager-plugin"
    "sf-symbols"
    "orbstack"
    "sol"
  ];

  workCasks = [
    "bettershot"
    "tableplus"
    "nurazon59/tap/gather-v2"
  ];

  personalCasks = [
    "discord"
    "whatsapp"
    "yksr-melt/Meltype/meltype"
  ];

  casks = commonCasks ++ (if user == "koshiishi" then workCasks else personalCasks);
in
{
  homebrew = {
    enable = true;
    greedyCasks = true;

    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;
    };

    taps = [
      {
        name = "FelixKratz/formulae";
        trusted = true;
      }
      {
        name = "nikitabobko/tap";
        trusted = true;
      }
      {
        name = "yksr-melt/Meltype";
        clone_target = "https://github.com/yksr-melt/Meltype";
        trusted = true;
      }
      {
        name = "nurazon59/tap";
        clone_target = "https://github.com/nurazon59/tap";
        trusted = true;
      }
    ];

    brews = [
      "ca-certificates"
      "curl"
      "ical-buddy"
      "sketchybar"
    ];

    casks = casks;
  };
}
