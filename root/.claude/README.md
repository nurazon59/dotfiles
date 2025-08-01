# Claude Code設定

このディレクトリにはClaude Codeの設定ファイルが含まれています。

## セットアップ手順

### 1. 設定ファイルのコピー
```bash
# テンプレートから個人設定を作成
cp root/.claude/settings.template.json root/.claude/settings.json

# 環境変数テンプレートをコピー（オプション）
cp root/.claude/.env.example root/.claude/.env
```

### 2. 個人設定のカスタマイズ
`settings.json`を編集して、個人の環境に合わせて調整してください。

### 3. 環境変数の設定（オプション）
システム環境変数として設定する場合：
```bash
export CLAUDE_LANGUAGE=ja
export CLAUDE_PACKAGE_MANAGER=mise
export CLAUDE_GIT_CLI=gh
```

## ファイル構成

- `CLAUDE.md` - メインの設定・ルールファイル（共有）
- `settings.template.json` - 設定テンプレート（共有）
- `settings.json` - 個人設定（gitignore対象）
- `.env.example` - 環境変数テンプレート（共有）
- `.env` - 個人環境変数（gitignore対象）
- `hooks/` - Claude Code hooks（共有）
- `commands/` - カスタムコマンド（共有）

## 設定優先順位

1. `settings.json` (個人設定)
2. 環境変数 (`CLAUDE_*`)
3. `CLAUDE.md` (デフォルト値)

## Hooks

Claude Code hooksが有効になっている場合：
- ファイル変更後に自動フォーマットが実行されます
- mise経由でeclintを使用してEditorConfig準拠の整形を行います

## トラブルシューティング

### 設定が反映されない場合
1. `settings.json`の存在確認
2. JSON形式の妥当性確認
3. 環境変数の設定確認

### hooksが動作しない場合
1. `hooks/`ディレクトリの存在確認
2. スクリプトの実行権限確認
3. miseの設定確認