{ pkgs }:
let
  lib = pkgs.lib;

  completions = {
    bat = {
      package = pkgs.bat;
      args = [ "--completion" "fish" ];
      output = "bat.fish";
    };

    bun = {
      package = pkgs.bun;
      args = [ "completions" ];
      output = "bun.fish";
    };

    ghq = {
      source = "${pkgs.ghq.src}/misc/fish/ghq.fish";
      output = "ghq.fish";
    };

    codex = {
      package = pkgs.codex;
      args = [ "completion" "fish" ];
      output = "codex.fish";
    };

    colima = {
      package = pkgs.colima;
      args = [ "completion" "fish" ];
      output = "colima.fish";
    };

    delta = {
      package = pkgs.delta;
      args = [ "--generate-completion" "fish" ];
      output = "delta.fish";
    };

    deno = {
      package = pkgs.deno;
      args = [ "completions" "fish" ];
      output = "deno.fish";
    };

    docker = {
      package = pkgs."docker-client";
      args = [ "completion" "fish" ];
      output = "docker.fish";
    };

    fd = {
      package = pkgs.fd;
      args = [ "--gen-completions" "fish" ];
      output = "fd.fish";
    };

    gh = {
      package = pkgs.gh;
      args = [ "completion" "-s" "fish" ];
      output = "gh.fish";
    };

    golangci-lint = {
      package = pkgs."golangci-lint";
      args = [ "completion" "fish" ];
      output = "golangci-lint.fish";
    };

    goreleaser = {
      package = pkgs.goreleaser;
      args = [ "completion" "fish" ];
      output = "goreleaser.fish";
    };

    lefthook = {
      package = pkgs.lefthook;
      args = [ "completion" "fish" ];
      output = "lefthook.fish";
    };

    pnpm = {
      package = pkgs.pnpm;
      args = [ "completion" "fish" ];
      output = "pnpm.fish";
    };

    rg = {
      package = pkgs.ripgrep;
      args = [ "--generate" "complete-fish" ];
      output = "rg.fish";
    };

    starship = {
      package = pkgs.starship;
      args = [ "completions" "fish" ];
      output = "starship.fish";
    };

    task = {
      package = pkgs."go-task";
      program = "task";
      args = [ "--completion" "fish" ];
      output = "task.fish";
    };

    uv = {
      package = pkgs.uv;
      args = [ "generate-shell-completion" "fish" ];
      output = "uv.fish";
    };

    wrangler = {
      package = pkgs.wrangler;
      args = [ "complete" "fish" ];
      output = "wrangler.fish";
    };

    xh = {
      package = pkgs.xh;
      args = [ "--generate" "complete-fish" ];
      output = "xh.fish";
    };
  };

  getCommand = cfg:
    if cfg ? program then
      lib.getExe' cfg.package cfg.program
    else
      lib.getExe cfg.package;

  renderOne = name: cfg:
    if cfg ? source then
      ''
        cp "${cfg.source}" "$out/share/fish/vendor_completions.d/${cfg.output}"
      ''
    else
      ''
      "${getCommand cfg}" ${lib.escapeShellArgs cfg.args} \
        > "$out/share/fish/vendor_completions.d/${cfg.output}"
      if [ ! -s "$out/share/fish/vendor_completions.d/${cfg.output}" ]; then
        echo "fish-generated-completions: empty output for ${name}" >&2
        exit 1
      fi
      '';
in
pkgs.runCommand "fish-generated-completions" { nativeBuildInputs = [ pkgs.coreutils ]; } ''
  mkdir -p "$out/share/fish/vendor_completions.d"

  ${lib.concatStringsSep "\n" (lib.mapAttrsToList renderOne completions)}
''
