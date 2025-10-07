# dotfiles

My personal development environment configuration files.

## Quick Start

### Using ghq (recommended)

```bash
ghq get nurazon59/dotfiles
cd $(ghq root)/github.com/nurazon59/dotfiles
./install.sh
```

### Manual clone

```bash
git clone https://github.com/nurazon59/dotfiles.git ~/src/github.com/nurazon59/dotfiles
cd ~/src/github.com/nurazon59/dotfiles
./install.sh
```

## Structure

```
dotfiles/
├── Brewfile            # Homebrew packages
├── bin/                # Utility scripts
├── config/
│   ├── .config/        # .config symlink
│   └── macos/          # macOS settings
├── root/               # Home directory files
│   ├── .gitconfig
│   ├── .gitignore
│   └── .zshrc
├── lefthook.yml        # Git hooks configuration
├── .lefthook/          # Hook scripts
└── install.sh          # Installation script
```

## Features

### Automatic Differential Installation

When you pull changes from the repository, lefthook automatically detects and installs only the changes:

- **Brewfile changes**: Installs only new packages
- **mise configuration**: Updates development tools
- **Config files**: Updates only modified symlinks

This feature is enabled automatically after running `install.sh`.
