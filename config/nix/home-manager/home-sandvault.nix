{ pkgs, lib, ... }:
let
  configDir = ../../.config;
in
{
  imports = [ ./mise.nix ];

  home.stateVersion = "24.11";
  home.username = "sandvault-koshiishi";
  home.homeDirectory = "/Users/sandvault-koshiishi";

  programs.ripgrep = {
    enable = true;
    package = pkgs.ripgrep;
    arguments = [
      "--ignore-file"
      "${configDir}/ripgrep/rgignore"
    ];
  };

  # sandvault では sign しない (host の signingkey/SSH agent は触れない)
  programs.git.settings.commit.gpgsign = false;

  # 設定ファイルのみ nix store 経由で配置 (read-only)。
  # untracked な秘匿 file (history.jsonl, sessions/, hosts.yml, fish_variables 等) を
  # 含めないため dir 丸ごとではなく whitelist で指定する。
  home.file = {
    ".config/git".source = configDir + "/git";
    ".config/gh/config.yml".source = configDir + "/gh/config.yml";

    ".config/claude/CLAUDE.md".source = configDir + "/claude/CLAUDE.md";
    ".config/claude/agents".source = configDir + "/claude/agents";
    ".config/claude/commands".source = configDir + "/claude/commands";
    ".config/claude/hooks".source = configDir + "/claude/hooks";
    ".config/claude/skills".source = configDir + "/claude/skills";
    ".config/claude/statusline.sh".source = configDir + "/claude/statusline.sh";
  };

  # settings.json は Claude Code が ~/.config/claude/.credentials.json 周辺と一緒に書き換える
  # ことがあるため symlink (read-only) では壊れる。初回のみコピーし、以降は sandvault user の
  # 書き換えを許容する。
  home.activation.copyClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.config/claude/settings.json" ]; then
      /usr/bin/install -m 0644 ${configDir}/claude/settings.json \
        "$HOME/.config/claude/settings.json"
    fi
  '';
}
