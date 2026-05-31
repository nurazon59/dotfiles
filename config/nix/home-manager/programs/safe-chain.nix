{ inputs, ... }:
{
  imports = [ inputs.safe-chain-nix.homeModules.default ];

  programs.safe-chain = {
    enable = true;
    integrationMode = "wrappers";
  };
}
