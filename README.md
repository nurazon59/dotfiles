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

### EditorConfig自動フォーマット

Claude Code hookとGit hookを使用した自動フォーマット機能:

#### 自動実行
- **Claude Code**: ファイル変更後に自動でEditorConfigルールを適用
- **Git pre-commit**: コミット前にステージファイルをチェック
- **Git pre-push**: プッシュ前にプロジェクト全体をチェック

#### 手動実行
```bash
# プロジェクト全体をチェック
mise run lint-editorconfig

# プロジェクト全体を修正
mise run fix-editorconfig

# 特定ファイルを修正
mise run format-changed-files file1.js file2.py
```

#### 必要な設定
- [mise](https://mise.jdx.dev/) がインストールされていること
- `.mise.toml` でnpm:eclintが設定済み
