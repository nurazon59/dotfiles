{
  config,
  lib,
  pkgs,
  ...
}:
let
  nvimConfig = import ../../neovim/config.nix { inherit pkgs; };
  profile = "${config.xdg.stateHome}/nvim-config/profile";
in
{
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink profile;

  home.activation.nvimConfigProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$(dirname "${profile}")"
    if [ ! -e "${profile}" ]; then
      run nix build --no-link --profile "${profile}" "${nvimConfig}"
    fi
  '';
}
