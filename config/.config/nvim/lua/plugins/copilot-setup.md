# GitHub Copilot セットアップ手順（blink.cmp対応版）

## 重要な変更点

`copilot-cmp`は`nvim-cmp`専用のため、`blink.cmp`用の`blink-cmp-copilot`を使用します。

## 1. プラグインのインストール

Neovimを再起動、またはLazyを再読み込みして、プラグインをインストール:

```vim
:Lazy sync
```

## 2. GitHub Copilotの認証

インストール後、Neovimで以下のコマンドを実行:

```vim
:Copilot auth
```

ブラウザが開くので、GitHubアカウントでログインして認証を完了する。

## 3. 動作確認

### 認証状態の確認

```vim
:Copilot status
```

「Copilot: Online」と表示されればOK

### 補完の動作確認

任意のコードファイルを開いて、コードを入力すると、blink.cmpの補完メニューに「Copilot」アイコン付きの提案が表示される。

## 4. 使用方法

### 補完メニューでの操作

- `Tab` または `Enter`: 選択中の補完を確定
- `Ctrl+n` / `Ctrl+p`: 補完候補の上下移動
- `Esc`: 補完メニューを閉じる

### CopilotChat（AIチャット機能）

- `<leader>cc`: チャットウィンドウを開く
- `<leader>cq`: クイックチャット（質問を入力）
- `<leader>ce`: コードの説明（選択範囲対応）
- `<leader>ct`: テスト生成（選択範囲対応）
- `<leader>cr`: コードレビュー（選択範囲対応）
- `<leader>cR`: リファクタリング提案（選択範囲対応）
- `<leader>cn`: より良い命名の提案（選択範囲対応）

## 5. トラブルシューティング

### Node.jsのバージョン確認

```bash
node --version  # v20以上が必要
```

### 認証をやり直す

```vim
:Copilot signout
:Copilot auth
```

### プラグインが正しくロードされているか確認

```vim
:Lazy
```

で`copilot.lua`と`blink-cmp-copilot`がインストールされているか確認

### ログの確認

```vim
:Copilot log
```

## 6. 設定のカスタマイズ

### Copilotを無効にしたいファイルタイプを追加

`~/.config/nvim/lua/plugins/copilot.lua`の`filetypes`セクションを編集:

```lua
filetypes = {
  yaml = false,
  markdown = false,
  help = false,
  gitcommit = false,
  gitrebase = false,
  [".env"] = false,  -- 追加例
}
```

### 補完の優先度を調整

`copilot.lua`の`score_offset`値を変更して、他の補完ソースとの優先順位を調整可能。

## 7. プラグイン構成

- **copilot.lua**: GitHub Copilotのコアクライアント（パネルと提案機能は無効化）
- **blink-cmp-copilot**: blink.cmp用のCopilotソースアダプター
- **CopilotChat.nvim**: AI支援チャット機能（オプション）
