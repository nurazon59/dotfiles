# dotfiles

My personal development environment configuration files.

## Quick Start

```bash
git clone https://github.com/itsuki54/dotfiles.git ~/src/dotfiles
cd ~/src/dotfiles
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