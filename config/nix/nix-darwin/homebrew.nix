{ pkgs, ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap";
    };

    taps = [
      "mtgto/macskk"
    ];

    brews = [
      "ical-buddy"
    ];

    casks = [
      "arc"
      "azookey"
      "claude"
      "clipy"
      "finetune"
      "font-sf-pro"
      "input-source-pro"
      "linearmouse"
      "notunes"
      "sf-symbols"
      "sol"
    ];
  };
}
