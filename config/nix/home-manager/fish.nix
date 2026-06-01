{ pkgs }:
let
  lib = pkgs.lib;

  # nixpkgsで入れたツールは installShellCompletion により
  # /share/fish/vendor_completions.d/<tool>.fish が自動配置される。
  # ここで扱うのは「nix外（mise / brew / native install）で導入したCLI」のみ。
  completions = {
    act = [
      "completion"
      "fish"
    ];
    aqua = [
      "completion"
      "fish"
    ];
    bun = [ "completions" ];
    codex = [
      "completion"
      "fish"
    ];
    deno = [
      "completions"
      "fish"
    ];
    gh = [
      "completion"
      "-s"
      "fish"
    ];
    ghalint = [
      "completion"
      "fish"
    ];
    ghmux = [
      "completion"
      "fish"
    ];
    golangci-lint = [
      "completion"
      "fish"
    ];
    goreleaser = [
      "completion"
      "fish"
    ];
    gwq = [
      "completion"
      "fish"
    ];
    lefthook = [
      "completion"
      "fish"
    ];
    nippo = [
      "completion"
      "fish"
    ];
    pinact = [
      "completion"
      "fish"
    ];
    pnpm = [
      "completion"
      "fish"
    ];
    rustup = [
      "completions"
      "fish"
    ];
    uv = [
      "generate-shell-completion"
      "fish"
    ];
    wrangler = [
      "complete"
      "fish"
    ];
  };

  renderOne =
    name: args:
    let
      argsStr = lib.concatStringsSep " " args;
    in
    ''
      cat > "$out/share/fish/vendor_completions.d/${name}.fish" <<SHIM_EOF
      if type -q ${name}
          ${name} ${argsStr} | source
      end
      SHIM_EOF
    '';
in
pkgs.runCommand "fish-generated-completions" { } ''
  mkdir -p "$out/share/fish/vendor_completions.d"

  ${lib.concatStringsSep "\n" (lib.mapAttrsToList renderOne completions)}
''
