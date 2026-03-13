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
