# Dotter導入ガイド

## Dotterとは

DotterはRust製のdotfilesマネージャーで、設定ファイルの管理を簡潔かつ強力に行えます。

## インストール

```bash
# Cargoでインストール（推奨）
cargo install dotter

# または miseを使用
mise use --global rust@latest
cargo install dotter
```

## 基本的な使い方

### 設定ファイル

- `.dotter/global.toml` - 全マシン共通の設定を定義
- `.dotter/local.toml` - マシン固有の設定（gitignore推奨）

### コマンド

```bash
# ドライラン（変更をプレビュー）
dotter deploy --dry-run

# デプロイ
dotter deploy

# ファイル監視モード
dotter watch

# アンデプロイ（シンボリックリンクを削除）
dotter undeploy
```

## 現在の設定

### パッケージ構成

- `default` - 基本的な設定ファイル（全環境共通）
- `macos` - macOS固有の設定（Aerospace、Karabiner等）
- `tex` - TeX関連の設定（オプション）
- `minimal` - テスト用の最小構成

### 使用例

1. 基本設定のみデプロイ:
```bash
# local.tomlを編集
packages = ["default"]

# デプロイ
dotter deploy
```

2. macOS環境でフル設定:
```bash
# local.tomlを編集
packages = ["default", "macos"]

# デプロイ
dotter deploy
```

## 既存のMakefileとの共存

現時点では、Dotterは既存のMakefileと共存可能です：

- **Makefile** - 初期セットアップ、ツールインストール等
- **Dotter** - 設定ファイルのシンボリックリンク管理

段階的にMakefileの機能をDotterに移行することを推奨します。

## トラブルシューティング

### 既存ファイルとの競合

既存ファイルがある場合、Dotterは警告を出します。`--force`オプションで上書き可能ですが、バックアップを取ることを推奨します。

### PATHの問題

Dotterが見つからない場合：
```bash
export PATH="$HOME/.cargo/bin:$PATH"
```

## 今後の改善点

1. テンプレート機能の活用（環境変数の動的展開）
2. フック機能でのセットアップ自動化
3. より詳細なパッケージ分割