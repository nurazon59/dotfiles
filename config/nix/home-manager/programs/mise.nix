{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.mise = {
    enable = true;
    package = inputs.mise.packages.${pkgs.stdenv.hostPlatform.system}.mise.overrideAttrs (oldAttrs: {
      nativeCheckInputs = (oldAttrs.nativeCheckInputs or [ ])
        ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.darwin.ps ];
    });
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/share/mise/shims"
  ];
}
