---
name: notion
description: >
  codex exec経由でNotion操作（検索・取得・作成・更新）を行う。コンテキスト節約のためClaude Code側のNotion
  MCPを使わず外部委託。「Notion読んで」「Notionみて」「notion.soのURL」を含むメッセージで起動。単発のNotionページ操作用。複数Notionソースを横断した調査・レポート作成にはnotion-research-documentationを使うこと。スキル定義ファイル(.md)の編集作業では起動しない。

---

# Notion via Codex Exec

Claude Codeのコンテキストを節約するため、Notion MCPアクセスをcodex execに委託する。

## 基本コマンド

```bash
# 検索（結果だけ受け取る）
codex exec --ephemeral -o /tmp/notion_result.txt \
  -c 'model_reasoning_effort="low"' -c 'web_search="disabled"' \
  "<プロンプト>" 2>/dev/null && cat /tmp/notion_result.txt

# 全文取得（ファイル書き出し → Readで読む）
codex exec --ephemeral -o /tmp/notion_done.txt \
  -c 'model_reasoning_effort="low"' -c 'web_search="disabled"' \
  "Notion MCPのfetchツールを使って、ID: <page_id> のページ全文を取得し、/tmp/notion_page_<page_id>.md にそのまま書き出して。加工・要約しない。完了したら「done」とだけ返して。" 2>/dev/null
```

## ユースケース別パターン

### 1. ページ検索
```bash
codex exec --ephemeral -o /tmp/notion_result.txt \
  -c 'model_reasoning_effort="low"' -c 'web_search="disabled"' \
  "Notion MCPを使って「<検索ワード>」を検索し、タイトルとIDを箇条書きで返して。" \
  2>/dev/null && cat /tmp/notion_result.txt
```
→ Claude Code側にはタイトル+IDの箇条書きだけが載る

### 2. ページ全文取得
```bash
codex exec --ephemeral -o /tmp/notion_done.txt \
  -c 'model_reasoning_effort="low"' -c 'web_search="disabled"' \
  "Notion MCPのfetchツールを使って、ID: <page_id> のページ全文を取得し、/tmp/notion_page.md にそのまま書き出して。加工・要約しない。完了したら「done」とだけ返して。" \
  2>/dev/null
```
→ その後 `Read /tmp/notion_page.md` で必要な部分だけ読む

### 3. ページ作成・更新
```bash
codex exec --ephemeral -o /tmp/notion_done.txt \
  -c 'model_reasoning_effort="low"' -c 'web_search="disabled"' \
  "Notion MCPのcreate-pagesツールを使って、以下の内容でページを作成して。親ページID: <parent_id>。タイトル: <title>。内容: <content>。完了したらURLを返して。" \
  2>/dev/null && cat /tmp/notion_done.txt
```

## コンテキスト最小化の原則

**データはファイルパスで持ち、必要な分だけReadする。**

- codex execの出力 → `-o` でファイルへ。stdoutに流さない
- 全文取得 → codexにファイル書き出しさせ、`Read` のoffset/limitで必要箇所だけ読む
- 複数ページ → `/tmp/notion_page_<page_id>.md` でファイル分離。全部読まず必要なものだけ
- 検索結果が少量（数行）なら `cat` でstdoutに流してOK

## コマンドオプション

| オプション | 目的 |
|---|---|
| `2>/dev/null` | stderrのMCPログ・thinkingを捨てる |
| `-o <file>` | codexの最終回答だけファイルへ |
| `-c 'model_reasoning_effort="low"'` | thinking最小化（gpt-5.4では`minimal`非対応、`low`が最小） |
| `-c 'web_search="disabled"'` | グローバル設定の`web_search="live"`を無効化（低reasoning effortと非互換） |
| `--ephemeral` | セッション履歴を残さない |

## Notion API挙動の落とし穴

codex経由でも直接MCP利用でも共通の Notion 側仕様。md 流し込み時に踏みがち。

### ページ更新（replace_content）

- **子ページがある親ページの `replace_content` は必ず失敗する**。エラーには子ページ一覧と「`<page url="...">` タグで含めるか `allow_deleting_content: true` を付けろ」と出る。子ページを残したい場合は new_str 末尾に `<page url="https://app.notion.com/p/<id>">title</page>` を列挙する
- **`<page url="..." />` の自己閉じ形式は認識されない**。閉じタグ必須（`<page url="...">title</page>`）

### Markdown レンダリング癖

- `[requirements.md](requirements.md)` のように **link text と href が同じドメイン風文字列** だと autolink 化されて href が捨てられる（`http://requirements.md` 表示になる）。link text を `requirements` 等に変えるか、href だけ Notion URL にして text を別表記にする
- `[design-review/requirements.md](url)` のように **link text に `/` を含む** と Notion 側で複数 link に視覚分割される（クリック先は同一なので機能上は OK）
- 先頭 H1 は properties の title と二重表示になるので、流し込み前に削る

### 大量ページの md 流し込み手順（27件級）

mapping JSON 永続化 → 2-pass。

1. 空コンテンツでページ作成 → `page_id` 収集 → `zzz/notion-pages.json` に `{ pages: { "<repo相対path>": { id, url } } }` で保存
2. `~/.config/claude/skills/notion/scripts/md-to-notion.mjs` を実行 → md を読み、相対リンク（`./xxx.md` / `../foo/bar.md`）を mapping から解決して Notion URL に置換、先頭 H1 を除去 → `zzz/notion-output/` に書き出し
3. 各ページに `replace_content` で流し込み。子持ち親ページは `<page url="...">title</page>` を末尾に必ず含める

```bash
node ~/.config/claude/skills/notion/scripts/md-to-notion.mjs
# default: --mapping ./zzz/notion-pages.json --repo . --out ./zzz/notion-output
```

mapping を持っておけば、後日「変更ファイルだけ Notion 更新」も `git diff` → 該当 page_id 引き → 変換スクリプト再実行 → 該当ページだけ `replace_content` で完結する。
