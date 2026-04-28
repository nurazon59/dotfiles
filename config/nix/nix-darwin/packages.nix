{ pkgs, neovim-nightly-overlay, ... }:
let
  neovim-nightly = neovim-nightly-overlay.packages.${pkgs.system}.default;
in
{
  environment.systemPackages = (with pkgs; [
    vim
    tmux
    nixd
    nixfmt
    btop
    lua
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
    ripgrep
    sd
    starship
    tree-sitter
    xh
    zoxide
    usage
    mprocs
    ollama
    ghq
    lazygit
    delta
    stylua
    go-task
    redis
    podman
    roslyn-ls
  ]) ++ [
    neovim-nightly
  ];
}
