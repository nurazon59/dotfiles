{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        overrideGpg = true;
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          }
        ];
        mainBranches = [
          "main"
          "master"
          "develop"
          "dev"
        ];
        parseEmoji = true;
      };
      gui = {
        nerdFontsVersion = "3";
        border = "single";
        authorColors = {
          "renovate[bot]" = "#737994";
        };
        theme = {
          activeBorderColor = [
            "#3e8fb0"
            "bold"
          ];
          inactiveBorderColor = [ "#6e6a86" ];
          searchingActiveBorderColor = [
            "#ea9a97"
            "bold"
          ];
          optionsTextColor = [ "#9ccfd8" ];
          selectedLineBgColor = [ "#3e8fb0" ];
          inactiveViewSelectedLineBgColor = [
            "#393552"
            "bold"
          ];
          cherryPickedCommitFgColor = [ "#2a273f" ];
          cherryPickedCommitBgColor = [ "#ea9a97" ];
          markedBaseCommitFgColor = [ "#9ccfd8" ];
          markedBaseCommitBgColor = [ "#f6c177" ];
          unstagedChangesColor = [ "#eb6f92" ];
          defaultFgColor = [ "#e0def4" ];
        };
        language = "en";
      };
      os.editPreset = "nvim-remote";
      quitOnTopLevelReturn = true;
    };
  };
}
