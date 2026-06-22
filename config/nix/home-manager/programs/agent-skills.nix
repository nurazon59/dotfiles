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
      "architecture-document"
      "gh-address-comments"
      "gh-fix-ci"
      "issue-creator"
      "merge-main"
      "pr"
      "pr-review-workflow"
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
