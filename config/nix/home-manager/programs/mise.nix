{ config, pkgs, ... }:
{
  programs.mise = {
    enable = true;
    package = pkgs.mise;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    globalConfig = {
      tools = {
        "aqua:suzuki-shunsuke/ghalint" = "latest";
        "cargo:mergiraf" = "latest";
        "dotnet:fantomas" = "latest";
        "dotnet:fsautocomplete" = "latest";
        "go:github.com/k1LoW/git-wt" = "latest";
        "go:github.com/nurazon59/ghmux" = "latest";
        "go:github.com/nurazon59/rport" = "latest";
        "go:github.com/nurazon59/nippo" = "latest";
        "go:github.com/jorgerojas26/lazysql" = "latest";
        "npm:@mermaid-js/mermaid-cli" = "latest";
        "npm:@openai/codex" = "latest";
        "npm:@playwright/cli" = "latest";
        "npm:ctx7" = "latest";
        "npm:difit" = "latest";
        "npm:docusaurus" = "latest";
        "npm:editprompt" = "latest";
        "npm:oxfmt" = "latest";
        "npm:typescript" = "latest";
        "npm:vercel" = "latest";
        "npm:wrangler" = "latest";

        act = "latest";
        aqua = "latest";
        aws = "latest";
        bun = "1.3.9";
        deno = "2.6.9";
        dotnet = "latest";
        ecspresso = "latest";
        gcloud = "latest";
        github-cli = "latest";
        go = "1.26.2";
        golangci-lint = "latest";
        goreleaser = "latest";
        lefthook = "latest";
        node = "24.13.1";
        pipx = "latest";
        pinact = "latest";
        pnpm = "latest";
        python = "3.14.3";
        rust = "1.93.1";
        terraform = "1.14.5";
        uv = "latest";
        yarn = "latest";
        opencode = "latest";
      };

      settings = {
        idiomatic_version_file_enable_tools = [ "python" ];
        experimental = true;
      };
    };
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/share/mise/shims"
  ];
}
