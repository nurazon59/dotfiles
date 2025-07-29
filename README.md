# dotfiles

My personal development environment configuration files.

## Quick Start

### Using ghq (recommended)

```bash
ghq get itsuki54/dotfiles
cd $(ghq root)/github.com/itsuki54/dotfiles
./install.sh
```

### Manual clone

```bash
git clone https://github.com/itsuki54/dotfiles.git ~/src/github.com/itsuki54/dotfiles
cd ~/src/github.com/itsuki54/dotfiles
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
└── install.sh          # Installation script
```