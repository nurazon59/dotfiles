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
│   ├── .latexmkrc      # LaTeX build configuration
│   ├── tex-packages.txt # TeX packages list
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

### TeX Environment (Optional)

The dotfiles include an optional TeX environment setup:

- **BasicTeX**: Minimal TeX distribution for macOS
- **Zathura**: Lightweight PDF viewer with automatic reload support
- **vimtex**: Neovim plugin for LaTeX editing with automatic compilation
- **latexmk**: Build automation with Japanese support (platex + dvipdfmx)

During `install.sh`, you'll be asked if you want to install the TeX environment. If you choose yes, BasicTeX, Zathura, and TeX packages listed in `config/tex-packages.txt` will be installed automatically.

#### Manual TeX Setup

If you need to install TeX packages manually:

```bash
# Update tlmgr itself
sudo tlmgr update --self

# Install packages from the list
cat config/tex-packages.txt | xargs sudo tlmgr install
```
