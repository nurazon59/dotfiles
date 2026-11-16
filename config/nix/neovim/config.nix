{ pkgs }:
let
  inherit (pkgs) lib;
  nvimConfig = ../../.config/nvim;
  pluginFiles = [
    "lua/config/lazy.lua"
    "lua/lsp/config.lua"
    "lua/plugins/ai.lua"
    "lua/plugins/colorscheme.lua"
    "lua/plugins/editor.lua"
    "lua/plugins/finder.lua"
    "lua/plugins/git.lua"
    "lua/plugins/github.lua"
    "lua/plugins/quickfix.lua"
    "lua/plugins/terminal.lua"
    "lua/plugins/testing.lua"
    "lua/plugins/treesitter.lua"
    "lua/plugins/ui.lua"
  ];
  artoRev = "5a00f0e977a035f8b098e0c4142e968a64f8efd2";
  arto = pkgs.vimUtils.buildVimPlugin {
    pname = "arto-vim";
    version = builtins.substring 0 7 artoRev;
    doCheck = false;
    src = pkgs.fetchFromGitHub {
      owner = "arto-app";
      repo = "arto.vim";
      rev = artoRev;
      hash = "sha256-Pet/wjh0Pv6HMPRKPsgNktpMIjqwiFW2zr/IeZ5Ht84=";
    };
  };
  gitlinkerRev = "d7adb5e4ba5bab4fd443a3f4c46af3f4c864685d";
  gitlinker = pkgs.vimUtils.buildVimPlugin {
    pname = "gitlinker.nvim";
    version = builtins.substring 0 7 gitlinkerRev;
    doCheck = false;
    src = pkgs.fetchFromGitHub {
      owner = "linrongbin16";
      repo = "gitlinker.nvim";
      rev = gitlinkerRev;
      hash = "sha256-jWoxp/Ux/fb7Diu5b3UaoTKv9a4WOlV9WLQ9TYUjJoI=";
    };
  };
  hardlineRev = "9b85ebfba065091715676fb440c16a37c465b9a5";
  hardline = pkgs.vimUtils.buildVimPlugin {
    pname = "nvim-hardline";
    version = builtins.substring 0 7 hardlineRev;
    doCheck = false;
    src = pkgs.fetchFromGitHub {
      owner = "ojroques";
      repo = "nvim-hardline";
      rev = hardlineRev;
      hash = "sha256-BY5uo5Fo9bAg0cy1GZLMglcc4lVt22q15PKIRIJgqd8=";
    };
  };
  pluginPaths = pkgs.vimPlugins // {
    "nvim-hardline" = hardline;
    "arto-vim" = arto;
    "lazy-nvim" = pkgs.vimPlugins.lazy-nvim;
    "gitlinker-nvim" = gitlinker;
    "sidekick-nvim" = pkgs.vimPlugins.sidekick-nvim.overrideAttrs {
      runtimeDeps = [ ];
    };
  };
  replacePluginRefs =
    file:
    let
      path = nvimConfig + "/${file}";
      source = builtins.readFile path;
      replacements = lib.filterAttrs (name: _: lib.hasInfix "@${name}@" source) pluginPaths;
    in
    pkgs.replaceVars path replacements;
in
pkgs.symlinkJoin {
  name = "nvim-config";
  paths = [ nvimConfig ];
  postBuild = lib.concatMapStrings (file: ''
    ln -sfn ${replacePluginRefs file} "$out/${file}"
  '') pluginFiles;
}
