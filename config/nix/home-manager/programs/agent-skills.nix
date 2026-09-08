{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  configDir = "${config.home.homeDirectory}/src/github.com/nurazon59/dotfiles/config/.config";
in
{
  imports = [ inputs.agent-skills.homeManagerModules.default ];
  programs.agent-skills = {
    enable = true;

    sources = {
      skills = {
        input = "skills";
      };
      mattpocock = {
        input = "mattpocock-skills";
        subdir = "skills";
      };
      caveman = {
        input = "caveman-skills";
        subdir = "skills";
        filter.nameRegex = "^caveman$";
      };
      natural-japanese = {
        input = "natural-japanese-skills";
        subdir = "skills";
        filter.nameRegex = "^natural-japanese$";
      };
      pull-request-review-context = {
        input = "pull-request-review-context";
        subdir = "skills";
      };
    };

    skills.enable = [
      "research"
      "architecture-document"
      "gh-address-comments"
      "gh-fix-ci"
      "issue-creator"
      "merge-main"
      "pr"
      "pr-review-workflow"
      "caveman"
      "natural-japanese"
      "pull-request-review-context"
    ];

    skills.explicit = {
      grill-me = {
        from = "mattpocock";
        path = "productivity/grill-me";
      };
      grill-with-docs = {
        from = "mattpocock";
        path = "engineering/grill-with-docs";
      };
    };

    targets = {
      agents.enable = true;

      opencode = {
        enable = true;
        dest = "${configDir}/opencode/skills";
      };

      claude = {
        enable = true;
        dest = "${configDir}/claude/skills";
      };

      codex = {
        enable = true;
        dest = "${configDir}/codex/skills";
      };
    };
  };
}
