{ config, lib, pkgs, inputs, ... }:
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
    };

    skills.enable = [
      "research"
      "notion"
      "architecture-document"
      "gh-address-comments"
      "gh-fix-ci"
      "issue-creator"
      "merge-main"
      "pr"
      "pr-review-workflow"
    ];

    skills.explicit.grill-me = {
      from = "mattpocock";
      path = "productivity/grill-me";
    };

    targets = {
      agents.enable = true;
      opencode.enable = true;
      claude = {
        enable = true;
        dest = "$HOME/.config/claude/skills";
      };
      codex = {
        enable = true;
        dest = "$HOME/.config/codex/skills";
      };
    };
  };
}
