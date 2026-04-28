{ user, config, pkgs, ... }:
let
  symlink = config.lib.file.mkOutOfStoreSymlink;
  dotfiles = "${config.home.homeDirectory}/src/github.com/nurazon59/dotfiles";
  configDir = "${dotfiles}/config/.config";
  rootDir = "${dotfiles}/config/root";
  fishGeneratedCompletions = import ./fish.nix { inherit pkgs; };
in
{
  imports = [ ./mise.nix ];

  home.stateVersion = "24.11";
  home.username = user;
  home.homeDirectory = "/Users/${user}";

  programs.ripgrep = {
    enable = true;
    package = null;
    arguments = [
      "--ignore-file"
      "${configDir}/ripgrep/rgignore"
    ];
  };

  home.file = {
    ".config/aerospace".source = symlink "${configDir}/aerospace";
    ".config/alacritty".source = symlink "${configDir}/alacritty";
    ".config/any-script-mcp".source = symlink "${configDir}/any-script-mcp";
    ".config/borders".source = symlink "${configDir}/borders";
    ".config/espanso".source = symlink "${configDir}/espanso";
    ".config/fish".source = symlink "${configDir}/fish";
    ".config/gh".source = symlink "${configDir}/gh";
    ".config/gh-dash".source = symlink "${configDir}/gh-dash";
    ".config/git".source = symlink "${configDir}/git";
    ".config/karabiner".source = symlink "${configDir}/karabiner";
    ".config/kitty".source = symlink "${configDir}/kitty";
    ".config/lazygit".source = symlink "${configDir}/lazygit";
    ".config/linearmouse".source = symlink "${configDir}/linearmouse";
    ".config/mprocs".source = symlink "${configDir}/mprocs";
    ".config/nix".source = symlink "${configDir}/nix";
    ".config/nvim".source = symlink "${configDir}/nvim";
    ".config/taplo".source = symlink "${configDir}/taplo";
    ".config/sheldon".source = symlink "${configDir}/sheldon";
    ".config/sketchybar".source = symlink "${configDir}/sketchybar";
    ".config/starship".source = symlink "${configDir}/starship";
    ".config/tmux".source = symlink "${configDir}/tmux";
    ".config/yazi".source = symlink "${configDir}/yazi";
    ".config/zeno".source = symlink "${configDir}/zeno";

    ".config/codex".source = symlink "${configDir}/codex";
    ".config/zsh".source = symlink "${configDir}/zsh";
    ".zshenv".source = symlink "${rootDir}/.zshenv";
  };

  home.packages = [ fishGeneratedCompletions ];
}
