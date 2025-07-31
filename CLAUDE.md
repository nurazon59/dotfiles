# Claude 設定ファイル

このファイルには、このリポジトリでのClaude Codeの動作に関する設定とルールが記載されています。

## プロジェクト概要
個人のdotfilesリポジトリです。macOS、Linux環境での開発環境セットアップに使用されます。

## 開発ルール

### コミットメッセージルール
- フォーマット: `<type>(<scope>): <subject>`
- subjectは日本語で記載すること
- 例: `feat(config): tmuxの設定を追加`
- 例: `fix(install): brewfileの依存関係修正`

**重要**: コミットメッセージには必ずユーザーの元の入力を`prompt:`として含めること
例:
```
feat(config): tmuxの設定を追加

prompt: tmuxの設定ファイルを追加して
```

### ブランチ命名規則
- feature/機能名
- fix/修正内容  
- docs/ドキュメント更新
- config/設定変更

### コードスタイル
- Shell script: ShellCheckに準拠
- YAML: yamllintに準拠
- 日本語コメント推奨

## 利用可能なツール
- homebrew (brew)
- git
- context7 mcp (コンテキスト管理)
- gemini (Google AI)

## 注意事項
- macOS固有の設定が多く含まれています
- 実行前に環境に応じた調整が必要な場合があります
- 機密情報は含めないでください

## ファイル構成
- `Brewfile`: homebrew dependencies
- `install.sh`: セットアップスクリプト
- `config/`: 各種設定ファイル
- `bin/`: 実行可能スクリプト