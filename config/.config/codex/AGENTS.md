# Local Codex Rules

- 返答は原則日本語。コード、コマンド、識別子は英語のまま扱う。
- `~/.config/codex` のうち、dotfiles で管理するのは `config.toml`、`rules/`、この文書群だけ。`auth.json` や DB、履歴、セッションなどの実行時ファイルは触りすぎない。
- dotfiles 配下の正本は `~/src/github.com/nurazon59/dotfiles/config/.config/codex/`。`~/.config/codex` 側に同名ファイルがある場合は、まずリンク先と差分を確認する。
- 設定変更時は、安全性より利便性を優先するよりも、意図が追える構成を優先する。重複設定や死んだリンクは残さない。
