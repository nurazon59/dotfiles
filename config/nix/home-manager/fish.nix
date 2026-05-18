{ pkgs }:
let
  lib = pkgs.lib;

  # nixpkgsでpackageを入れている場合 installShellCompletion で
  # /share/fish/vendor_completions.d/<tool>.fish が自動配置されるため
  # ここでは「mise管理 = nix外で導入」しているCLIだけを対象にする
  completions = {
    bun = {
      package = pkgs.bun;
      args = [ "completions" ];
      output = "bun.fish";
    };

    deno = {
      package = pkgs.deno;
      args = [
        "completions"
        "fish"
      ];
      output = "deno.fish";
    };

    gh = {
      package = pkgs.gh;
      args = [
        "completion"
        "-s"
        "fish"
      ];
      output = "gh.fish";
    };

    golangci-lint = {
      package = pkgs."golangci-lint";
      args = [
        "completion"
        "fish"
      ];
      output = "golangci-lint.fish";
    };

    goreleaser = {
      package = pkgs.goreleaser;
      args = [
        "completion"
        "fish"
      ];
      output = "goreleaser.fish";
    };

    lefthook = {
      package = pkgs.lefthook;
      args = [
        "completion"
        "fish"
      ];
      output = "lefthook.fish";
    };

    pnpm = {
      package = pkgs.pnpm;
      args = [
        "completion"
        "fish"
      ];
      output = "pnpm.fish";
    };

    uv = {
      package = pkgs.uv;
      args = [
        "generate-shell-completion"
        "fish"
      ];
      output = "uv.fish";
    };

    # wrangler は nixpkgs が installShellCompletion で fish を入れていない
    wrangler = {
      package = pkgs.wrangler;
      args = [
        "complete"
        "fish"
      ];
      output = "wrangler.fish";
    };
  };

  getCommand =
    cfg: if cfg ? program then lib.getExe' cfg.package cfg.program else lib.getExe cfg.package;

  renderOne =
    name: cfg:
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
