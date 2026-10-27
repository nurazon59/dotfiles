{
  user,
  config,
  pkgs,
  inputs,
  ...
}:
let
  lib = pkgs.lib;
  symlink = config.lib.file.mkOutOfStoreSymlink;
  dotfiles = "${config.home.homeDirectory}/src/github.com/nurazon59/dotfiles";
  configDir = "${dotfiles}/config/.config";
  rootDir = "${dotfiles}/config/root";
  fishGeneratedCompletions = import ./fish.nix { inherit pkgs; };
in
{
  imports = [
    ./programs/agent-skills.nix
    ./programs/firefox.nix
    ./programs/mise.nix
    ./programs/neovim.nix
    ./programs/nh.nix
    ./programs/nix-your-shell.nix
    ./programs/ripgrep.nix
    ./programs/safe-chain.nix
    ./programs/zen.nix
  ];

  home.stateVersion = "24.11";
  home.enableNixpkgsReleaseCheck = false;
  home.username = user;
  home.homeDirectory = "/Users/${user}";

  services.jankyborders = {
    enable = true;
    settings = {
      style = "round";
      width = 5.0;
      hidpi = "on";
      active_color = "0xc0ffffff";
    };
  };

  launchd.agents.jankyborders.config.KeepAlive = pkgs.lib.mkForce false;

  xdg.enable = true;

  home.sessionVariables = {
    TAPLO_CONFIG = "${config.xdg.configHome}/taplo/taplo.toml";
    npm_config_cache = "${config.xdg.cacheHome}/npm";
    pnpm_config_store_dir = "${config.xdg.dataHome}/pnpm/store";
    GOCACHE = "${config.xdg.cacheHome}/go-build";
    GOMODCACHE = "${config.xdg.cacheHome}/go/mod";
    PIP_CACHE_DIR = "${config.xdg.cacheHome}/pip";
    BUN_INSTALL_CACHE_DIR = "${config.xdg.cacheHome}/bun/install/cache";
    PI_CODING_AGENT_DIR = "${config.xdg.configHome}/pi";
    LANG = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "bat";
    BAT_PAGER = "less -R";
    FZF_DEFAULT_OPTS = "--height 40% --reverse --cycle --bind tab:down,btab:up";
    FZF_COMPLETION_OPTS = "--select-1 --exit-0 --preview='bat -n --color=always {1} 2>/dev/null || lsd --color=always -a {1} 2>/dev/null' --preview-window=right:50%:wrap:border-left";
    STARSHIP_CONFIG = "${config.xdg.configHome}/starship/starship.toml";
    CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
    CODEX_HOME = "${config.xdg.configHome}/codex";
    DOCKER_HOST = "unix://${config.xdg.configHome}/colima/default/docker.sock";
  };

  home.sessionPath = lib.mkBefore [
    "${config.home.homeDirectory}/.local/share/mise/installs/tree-sitter/latest"
    config.xdg.binHome
    "/opt/homebrew/opt/curl/bin"
    "/opt/homebrew/bin"
  ];

  home.file = {
    ".config/aerospace".source = symlink "${configDir}/aerospace";
    ".config/alacritty".source = symlink "${configDir}/alacritty";
    ".config/any-script-mcp".source = symlink "${configDir}/any-script-mcp";
    ".config/espanso".source = symlink "${configDir}/espanso";
    ".config/emacs".source = symlink "${configDir}/emacs";
    ".config/fish".source = symlink "${configDir}/fish";
    ".config/gh".source = symlink "${configDir}/gh";
    ".config/ghtkn".source = symlink "${configDir}/ghtkn";
    ".config/gh-dash".source = symlink "${configDir}/gh-dash";
    ".config/git".source = symlink "${configDir}/git";
    ".config/gitu".source = symlink "${configDir}/gitu";
    ".config/gwq".source = symlink "${configDir}/gwq";
    ".config/karabiner".source = symlink "${configDir}/karabiner";
    ".config/kitty".source = symlink "${configDir}/kitty";
    ".config/linearmouse".source = symlink "${configDir}/linearmouse";
    ".config/mise".source = symlink "${configDir}/mise";
    ".config/mprocs".source = symlink "${configDir}/mprocs";
    ".config/nix".source = symlink "${configDir}/nix";
    ".config/pi".source = symlink "${configDir}/pi";
    ".config/taplo".source = symlink "${configDir}/taplo";
    ".config/sheldon".source = symlink "${configDir}/sheldon";
    ".config/sketchybar".source = symlink "${configDir}/sketchybar";
    ".config/starship".source = symlink "${configDir}/starship";
    ".config/tmux".source = symlink "${configDir}/tmux";
    ".config/tridactyl".source = symlink "${configDir}/tridactyl";
    ".config/wezterm".source = symlink "${configDir}/wezterm";
    ".config/yazi".source = symlink "${configDir}/yazi";
    ".config/zeno".source = symlink "${configDir}/zeno";

    ".config/claude".source = symlink "${configDir}/claude";
    ".config/codex".source = symlink "${configDir}/codex";
    ".config/opencode".source = symlink "${configDir}/opencode";
    ".config/zsh".source = symlink "${configDir}/zsh";
    ".zshenv".source = symlink "${rootDir}/.zshenv";
  };

  programs.gpg = {
    enable = true;
    settings = {
      trust-model = "tofu+pgp";
      default-key = "82A818377A25B08C";
    };
    publicKeys = [
      {
        source = ./gpg-public-key.asc;
        trust = 5;
      }
    ];
  };

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentry.package = pkgs.pinentry_mac;
  };

  home.packages = [
    fishGeneratedCompletions
    pkgs.ghmux
    pkgs.nippo
    pkgs.pull-request-review-context
    pkgs.rport
    pkgs.nerd-fonts-0xproto-nurazon59
    pkgs.sketchybar-app-font
    pkgs.slack
    pkgs.tridactyl-native
    inputs.nix-claude-code.packages.${pkgs.system}.latest
    inputs.codex-cli-nix.packages.${pkgs.system}.codex
  ];
}
