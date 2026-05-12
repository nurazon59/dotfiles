{
  pkgs,
  lib,
  ...
}:
let
  hostUser = "koshiishi";
  sharedRoot = "/Users/Shared/sv-${hostUser}";
  claudeSv = pkgs.writeShellApplication {
    name = "claude-sv";
    runtimeInputs = with pkgs; [
      coreutils
      git
    ];
    text = builtins.readFile ./claude-sv.sh;
  };
in
{
  home.packages = [ claudeSv ];

  # sandvault user が読める Shared/bin に shim を配置 (darwin-rebuild ごとに上書き)。
  # ${sharedRoot}/bin が無ければ activation を fail させる (bootstrap 未実行を早期検知)。
  home.activation.svInstallShim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/install -m 0755 ${./sandbox-init.sh} "${sharedRoot}/bin/sandbox-init"
  '';
}
