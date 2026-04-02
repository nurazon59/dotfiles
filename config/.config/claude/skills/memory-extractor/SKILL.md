---
name: memory-extractor
description: >
  セッション履歴からメモリに保存すべき知見を自動抽出する。
  パターン・設定・設計判断・解決策をカテゴリ分類し、既存メモリと重複排除した上で
  ユーザー承認後にメモリファイルへ書き込む。
  「メモリ抽出」「memory extract」「セッションからメモリ」「知見を保存」
  「remember from sessions」などで起動。
---

# Memory Extractor

セッション履歴を分析し、永続化すべき知見をメモリに自動保存するワークフロー。

## Workflow

### Step 0: 設定確認

AskUserQuestionで以下を確認：

1. **対象範囲**: 「対象プロジェクトは？ (current / all)」 — デフォルト: current
2. **期間**: 「直近何日分を分析？」 — デフォルト: 14日
3. **対象プロジェクト（allの場合）**: プロジェクト一覧を表示して選択

### Step 1: 会話データ収集

```bash
python3 scripts/extract_conversations.py <project-or-"all"> \
  --days <N> --min-turns 2 --max-chars 500 \
  --output <workspace>/conversations.json --verbose
```

`<workspace>` は `zzz/memory-extractor-<timestamp>/` を使用する。

収集サマリをユーザーに報告：
「N sessions, M turns を収集しました。分析を開始します。」

### Step 2: 既存メモリ読み込み

現在のプロジェクトのメモリディレクトリを読み込む：

```
~/.claude/projects/<encoded-project>/memory/
```

- `MEMORY.md` があれば内容を読む
- その他の `.md` ファイルも読む
- 内容を `<workspace>/existing-memory.txt` に書き出す

allモードの場合は全プロジェクトのメモリを収集。

### Step 3: 知見抽出（Sub-agents）

conversations.json をバッチに分割し、knowledge-extractor sub-agentを並列起動。

**バッチ分割ルール:**
- プロジェクト別にグループ化
- 1バッチ最大30セッション
- MAX_BATCHES = 8

各sub-agentへの指示：

```
Agent tool (sonnet, general-purpose):
  "Read agents/knowledge-extractor.md from the memory-extractor skill directory.
   Read <workspace>/conversations.json — analyze only sessions at indices [list].
   Read <workspace>/existing-memory.txt for dedup context.
   Write findings as JSON to <workspace>/batch-<i>.json.
   出力は日本語で。JSON以外は出力しないこと。"
```

### Step 4: マージ＆重複排除

全バッチ結果を統合：

1. 全 `batch-*.json` を読み込む
2. findings を統合
3. 重複排除:
   - 同じ title + category の項目はマージ（evidenceを結合、confidenceを上げる）
   - 既存メモリと内容が重複する項目は除外
4. confidence: high のみ残す（medium は件数だけ報告）
5. 結果を `<workspace>/merged-findings.json` に書き出す

### Step 5: ユーザー承認

抽出結果をカテゴリ別に表示：

```
## 抽出結果

### Patterns (3件)
1. [auth-one] Goテストでtestcontainersを使う (confidence: high)
   → patterns.md に追記
2. ...

### Preferences (1件)
...

### 保留 (medium confidence: 5件)
次回のセッション分析で再確認します。
```

ユーザーに「保存してよいですか？ (y/n/番号で個別選択)」と確認。

### Step 6: メモリ書き込み

承認された項目をメモリファイルに書き込む：

- **グローバル項目**: `~/.claude/projects/<current-project>/memory/MEMORY.md` に追記
- **プロジェクト固有項目**: suggested_file に基づいてファイルを作成/追記
- **MEMORY.md** が200行を超えないよう注意。超える場合は別ファイルに分離し、MEMORY.mdからリンク

書き込み時は Edit ツールで既存ファイルに追記。新規ファイルのみ Write を使用。

### Step 7: サマリ報告

```
## 完了

- 分析: N sessions / M turns
- 抽出: X 件 (high confidence)
- 保留: Y 件 (medium, 次回再確認)
- 保存先:
  - memory/MEMORY.md (2件追記)
  - memory/patterns.md (新規作成, 3件)
- workspace: zzz/memory-extractor-<timestamp>/
```

## ワークスペース構造

```
zzz/memory-extractor-<timestamp>/
├── conversations.json          # 抽出した会話データ
├── existing-memory.txt         # 既存メモリ内容
├── batch-0.json ... batch-N.json  # sub-agent出力
└── merged-findings.json        # マージ済み結果
```

## 注意事項

- 機密情報（トークン、パスワード、社内URL）はメモリに書かない
- MEMORY.md は200行以内に収める
- medium confidence の項目は保存せず、次回分析時に再評価
- sub-agentにはsonnetを指定してコスト効率を上げる
