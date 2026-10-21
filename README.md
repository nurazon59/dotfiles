# dotfiles

macOS dev environment managed with nix-darwin + home-manager.

## Setup

```bash
curl -fsSL https://raw.githubusercontent.com/nurazon59/dotfiles/main/install.sh | sh -s -- work
# or
curl -fsSL https://raw.githubusercontent.com/nurazon59/dotfiles/main/install.sh | sh -s -- personal

cd ~/src/github.com/nurazon59/dotfiles
make rebuild           # after config changes
```

## Neovim config

After the first `make rebuild` connects `~/.config/nvim` to the standalone profile, Lua changes can be built and applied without rebuilding nix-darwin:

```bash
make nvim-build
make nvim-apply
make nvim-rollback     # return to the previous applied generation
```

`make nvim-apply` updates the profile at `${XDG_STATE_HOME:-~/.local/state}/nvim-config/profile`. The profile keeps generations and their store paths available for rollback and garbage collection.
