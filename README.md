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

### EditorConfig Integration

Automatic code formatting and linting using mise and eclint:

- **mise管理**: npmパッケージ（eclint）をmiseで管理
- **Claude Code Hook**: ファイル変更後に自動フォーマット実行
- **Git Hook**: コミット前/プッシュ前の自動チェック

#### 使用コマンド

```bash
# EditorConfigチェック
mise run lint-editorconfig

# EditorConfig修正
mise run fix-editorconfig

# 特定ファイルのフォーマット
mise run format-changed-files file1.js file2.py
```
