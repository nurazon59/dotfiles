# Fish Native Prompt

fishネイティブのプロンプトとstarshipを切り替える方法：

## Starshipを無効化してネイティブプロンプトを使用

```fish
# config.fishで以下の行をコメントアウト
# starship init fish | source

# fish_promptを有効化
cp ~/.config/fish/functions/fish_prompt_native.fish ~/.config/fish/functions/fish_prompt.fish
cp ~/.config/fish/functions/fish_right_prompt_native.fish ~/.config/fish/functions/fish_right_prompt.fish
```

## Starshipに戻す

```fish
# config.fishで以下の行のコメントを外す
starship init fish | source

# ネイティブプロンプトを削除
rm ~/.config/fish/functions/fish_prompt.fish
rm ~/.config/fish/functions/fish_right_prompt.fish
```

## fishネイティブの利点

1. **高速**: 外部プロセスを起動しないので高速
2. **カスタマイズ性**: fish関数で完全に制御可能
3. **依存なし**: starshipのインストール不要
4. **fish統合**: fishの機能をフル活用

## fishネイティブでできること

- カラー設定: `set_color` コマンド
- Git情報: `fish_git_prompt` または独自実装
- 実行時間: `$CMD_DURATION` 変数
- 終了ステータス: `$status` 変数
- viモード表示: `fish_mode_prompt`
- 非同期処理: `fish_update_completions`でバックグラウンド更新

## カスタマイズ例

```fish
# Git設定
set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showstashstate 1
set -g __fish_git_prompt_showuntrackedfiles 1
set -g __fish_git_prompt_showupstream 1
```