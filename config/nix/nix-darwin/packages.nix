{
  pkgs,
  neovim-nightly-overlay,
  arto,
  pi,
  mise,
  user,
  ...
}:
let
  neovim-nightly = neovim-nightly-overlay.packages.${pkgs.system}.default;
  arto-pkg = arto.packages.${pkgs.system}.default;
  isPersonal = user == "itsuki54";
in
{
  environment.systemPackages =
    (with pkgs; [
      vim
      tmux
      nixd
      nixfmt
      btop
      lua5_5
      lima
      postgresql_18
      pgformatter
      qemu
      sheldon
      switchaudio-osx
      bat
      colima
      direnv
      docker-client
      fd
      fzf
      lsd
      sd
      starship
      tree-sitter
      xh
      zoxide
      usage
      mprocs
      ghq
      delta
      stylua
      go-task
      redis
      podman
      roslyn-ls
      just
      macism
      cmake
      wezterm
      trivy
      osv-scanner
      gitleaks
      alacritty
      gitu
      kubectl
      rtk
      ghgrab
      _1password-cli
      plantuml
      emacs
      pi.packages.${pkgs.system}.coding-agent
      (google-cloud-sdk.withExtraComponents (
        with google-cloud-sdk.components;
        [
          gke-gcloud-auth-plugin
        ]
      ))
      (mise.packages.${pkgs.system}.mise.overrideAttrs (oldAttrs: {
        nativeCheckInputs = (oldAttrs.nativeCheckInputs or [ ])
          ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.darwin.ps ];
      }))
    ])
    ++ [
      neovim-nightly
      arto-pkg
    ]
    ++ (if isPersonal then [ pkgs.ollama ] else [ ]);
}
