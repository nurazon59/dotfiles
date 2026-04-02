{ pkgs, ... }:
{
  homebrew = {
    enable = true;

    taps = [
      "daipeihust/tap"
      "felixkratz/formulae"
      "mtgto/macskk"
      "nikitabobko/tap"
    ];

    brews = [
      "daipeihust/tap/im-select"
      "felixkratz/formulae/borders"
      "felixkratz/formulae/sketchybar"
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
    ];
  };
}
