# dotfiles

My personal development environment configuration files.

## Quick Start

```bash
# Using ghq (recommended)
ghq get itsuki54/dotfiles
cd $(ghq root)/github.com/itsuki54/dotfiles
./install.sh

# Or manual clone
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