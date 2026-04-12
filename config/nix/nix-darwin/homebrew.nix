{ pkgs, ... }:
{
  homebrew = {
    enable = true;

    taps = [
      "felixkratz/formulae"
      "mtgto/macskk"
      "nikitabobko/tap"
      "laishulu/homebrew"
    ];

    brews = [
      "felixkratz/formulae/borders"
      "felixkratz/formulae/sketchybar"
      "laishulu/homebrew/macism"
    ];

    casks = [
      "1password"
      "nikitabobko/tap/aerospace"
      "alacritty"
      "arc"
      "azookey"
      "clipy"
      "datagrip"
      "espanso"
      "finetune"
      "font-0xproto-nerd-font"
      "font-sf-pro"
      "font-sketchybar-app-font"
      "input-source-pro"
      "karabiner-elements"
      "linearmouse"
      "monitorcontrol"
      "sf-symbols"
      "shottr"
      "slack"
      "sol"
    ];
  };
}
