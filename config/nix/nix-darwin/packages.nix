{ pkgs, neovim-nightly-overlay, arto, ... }:
let
  neovim-nightly = neovim-nightly-overlay.packages.${pkgs.system}.default;
  arto-pkg = arto.packages.${pkgs.system}.default;
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
      ollama
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
      mise
      wezterm
      trivy
      osv-scanner
      gitleaks
    ])
    ++ [
      neovim-nightly
      arto-pkg
    ];
}
