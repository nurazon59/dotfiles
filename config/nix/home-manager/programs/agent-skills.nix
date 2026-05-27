{ config, lib, pkgs, inputs, ... }:
let
  dotfiles = ../../../..;
in
{
  imports = [ inputs.agent-skills.homeManagerModules.default ];

  programs.agent-skills = {
    enable = true;

    sources = {
      dotfiles = {
        path = "${dotfiles}/config/.agents/skills";
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
      "productivity/grill-me"
      "gh-address-comments"
      "gh-fix-ci"
      "issue-creator"
      "merge-main"
      "pr"
      "pr-review-workflow"
    ];

    targets = {
      agents.enable = true;
      opencode.enable = true;
      claude.enable = true;
      codex.enable = true;
    };
  };
}
