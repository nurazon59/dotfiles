# レビュー指摘修正コマンド（大量subagent方式）

`/review-pr-full` の結果を読み込み、**各指摘ごとに専用subagentを起動**して修正する。

## 引数

- `$ARGUMENTS`: レビュー結果ディレクトリのパス（省略時は最新のzzz/review-*を使用）

## 実行手順

### Phase 0: 準備・指摘抽出

1. レビュー結果の読み込み
   ```bash
   REVIEW_DIR=${ARGUMENTS:-$(ls -td zzz/review-* 2>/dev/null | head -1)}
   ```

2. FINAL-REPORT.mdと各観点mdを読み込み、指摘をすべてリストアップ
   - 指摘ID、重要度、観点、ファイル、行番号、内容を抽出
   - 修正可能な指摘と手動対応が必要な指摘を分類

3. `zzz/fix-{ブランチ名}-{日付}/` ディレクトリを作成

4. 指摘リストを `zzz/fix-{}/issues.json` に出力:
   ```json
   {
     "critical": [
       {"id": "C001", "category": "security", "file": "src/api.ts", "line": 42, "issue": "SQLインジェクション", "agent": "general-purpose"},
       {"id": "C002", "category": "error", "file": "src/handler.ts", "line": 15, "issue": "サイレント失敗", "agent": "general-purpose"}
     ],
     "high": [...],
     "medium": [...],
     "low": [...]
   }
   ```

---

## Phase 1: 大量subagent修正（3並列 × N回）

### 修正戦略

**1指摘 = 1 subagent** で修正。3並列で回す。

```
指摘リスト: [C001, C002, C003, H001, H002, H003, H004, M001, M002, ...]
                ↓
Round 1: [C001, C002, C003] → 3並列で修正
Round 2: [H001, H002, H003] → 3並列で修正
Round 3: [H004, M001, M002] → 3並列で修正
...
```

---

### 🔧 Critical修正（全て完了するまで）

各Critical指摘に対して:

| 指摘ID | Agent | 出力 |
|--------|-------|------|
| C001 | `general-purpose` | `fixes/C001-security.md` |
| C002 | `general-purpose` | `fixes/C002-error.md` |
| ... | ... | ... |

**agentへの指示テンプレート:**
```
以下の指摘を修正してください。

## 指摘内容
- ID: {id}
- 重要度: Critical
- カテゴリ: {category}
- ファイル: {file}
- 行: {line}
- 問題: {issue}
- 詳細: {details from 観点別md}

## 修正手順
1. 該当ファイルを読み込む
2. 問題箇所を特定
3. 修正を実施
4. 修正内容を `zzz/fix-{dir}/fixes/{id}-{category}.md` に記録
5. **修正したファイルをコミット**（下記フォーマット）

## コミットフォーマット
fix({category}): {issue の要約}

- ID: {id}
- File: {file}:{line}
- 修正内容: {簡潔な説明}

prompt: /fix-review による自動修正

## 出力フォーマット
- 修正前のコード
- 修正後のコード
- 修正理由
- 影響範囲
- コミットハッシュ
```

---

### 🔧 High修正（全て完了するまで）

Critical完了後、High指摘を同様に3並列で修正。

| 指摘カテゴリ | 推奨Agent |
|-------------|-----------|
| コード品質 | `pr-review-toolkit:code-simplifier` |
| 型設計 | `typescript-pro` または `pr-review-toolkit:type-design-analyzer` |
| アーキテクチャ | `feature-dev:code-architect` |
| パフォーマンス | `react-frontend-specialist` (React) / `general-purpose` |
| テスト不足 | `general-purpose` |

---

### 🔧 Medium修正（全て完了するまで）

High完了後、Medium指摘を同様に修正。

| 指摘カテゴリ | 推奨Agent |
|-------------|-----------|
| コメント品質 | `pr-review-toolkit:comment-analyzer` |
| 不要コメント | `comment-cleaner` |
| ドキュメント | `general-purpose` |
| UI改善 | `ui-design-specialist` |
| a11y | `accessibility-compliance:ui-visual-validator` |

---

### 🔧 Low修正（オプション）

`--include-low` フラグ指定時のみ実行。

---

## Phase 2: 検証（3並列）

### 🔍 検証Wave

修正完了後、以下の検証を3並列で実行:

| Agent | タスク | 出力 |
|-------|--------|------|
| `pr-review-toolkit:code-reviewer` | 修正後のコード品質確認 | `verify/code-quality.md` |
| `general-purpose` | Critical/High解消確認 | `verify/issue-resolution.md` |
| `general-purpose` | 新規問題・デグレ検出 | `verify/regression.md` |

---

## Phase 3: 集約レポート

### まとめagent

全ての `fixes/*.md` と `verify/*.md` を読み込み、最終レポートを生成。

**出力**: `zzz/fix-{}/FIX-REPORT.md`

---

## 実行フロー図

```
FINAL-REPORT.md + 各観点md
        ↓
    指摘抽出・リスト化
        ↓
    issues.json 生成
        ↓
┌─────────────────────────────────────────┐
│  Critical修正 (3並列 × ceil(N/3)回)     │
│  [C001] [C002] [C003] → 並列修正        │
│       ↓ 各完了後に個別コミット          │
│  [C004] [C005] [C006] → 並列修正        │
│       ↓ 各完了後に個別コミット          │
│  ...                                    │
└─────────────────────────────────────────┘
        ↓ 全Critical完了
┌─────────────────────────────────────────┐
│  High修正 (3並列 × ceil(N/3)回)         │
│  [H001] [H002] [H003] → 並列修正        │
│       ↓ 各完了後に個別コミット          │
│  [H004] [H005] [H006] → 並列修正        │
│       ↓ 各完了後に個別コミット          │
│  ...                                    │
└─────────────────────────────────────────┘
        ↓ 全High完了
┌─────────────────────────────────────────┐
│  Medium修正 (3並列 × ceil(N/3)回)       │
│  [M001] [M002] [M003] → 並列修正        │
│       ↓ 各完了後に個別コミット          │
│  ...                                    │
└─────────────────────────────────────────┘
        ↓ 全Medium完了
┌─────────────────────────────────────────┐
│  検証 (3並列)                           │
│  [品質確認] [解消確認] [デグレ検出]      │
└─────────────────────────────────────────┘
        ↓
    まとめagent → FIX-REPORT.md
```

---

## ディレクトリ構造

```
zzz/fix-feature-auth-20241217-1500/
├── issues.json              # 指摘リスト
├── fixes/                   # 各指摘の修正ログ
│   ├── C001-security.md
│   ├── C002-error.md
│   ├── H001-type.md
│   ├── H002-performance.md
│   ├── M001-comment.md
│   └── ...
├── verify/                  # 検証結果
│   ├── code-quality.md
│   ├── issue-resolution.md
│   └── regression.md
└── FIX-REPORT.md           # 最終レポート
```

---

## 修正レポートフォーマット

```markdown
# 修正レポート

**元レビュー**: {REVIEW_DIRのパス}
**修正日時**: {日時}
**ブランチ**: {ブランチ名}

---

## 修正サマリー

| 重要度 | 指摘数 | 修正数 | スキップ | 理由 |
|--------|--------|--------|----------|------|
| 🔴 Critical | X | X | 0 | - |
| 🟠 High | X | X | X | {理由} |
| 🟡 Medium | X | X | X | {理由} |
| 🟢 Low | X | 0 | X | 優先度低のためスキップ |

---

## 修正詳細

### Critical修正

| # | 指摘内容 | 修正内容 | ファイル | コミット |
|---|---------|---------|----------|----------|
| 1 | ... | ... | ... | `abc1234` |

### High修正

| # | 指摘内容 | 修正内容 | ファイル | コミット |
|---|---------|---------|----------|----------|

### Medium修正

| # | 指摘内容 | 修正内容 | ファイル | コミット |
|---|---------|---------|----------|----------|

---

## 追加テスト

| # | テストファイル | テスト内容 | カバー対象 |
|---|---------------|-----------|-----------|

---

## 再レビュー結果

### ✅ 解消確認済み
- {解消された指摘のリスト}

### ⚠️ 要確認
- {修正したが確認が必要な項目}

### 🆕 新規検出
- {修正により新たに検出された問題}

---

## 残作業

- [ ] {手動対応が必要な項目}
- [ ] {ユーザー判断が必要な項目}

---

## コミット履歴

```
{git log --oneline の出力}
```

---

## 次のステップ

1. `git log --oneline` で修正コミットを確認
2. テストを実行して問題がないか確認
3. 問題があれば該当コミットを `git revert` で取り消し
4. 問題なければPR作成へ
```

---

## 実行フロー図

```
FINAL-REPORT.md 読み込み
        ↓
指摘の抽出・分類
        ↓
Wave 1 ─┬─ セキュリティ修正
        ├─ エラーハンドリング修正   [Critical]
        └─ 言語固有修正
                ↓
Wave 2 ─┬─ コード簡素化
        ├─ 型設計改善              [High]
        └─ アーキテクチャ改善
                ↓
Wave 3 ─┬─ コメント改善
        ├─ 不要コメント削除        [Medium]
        └─ ドキュメント更新
                ↓
Wave 4 ─┬─ ユニットテスト追加
        ├─ エッジケーステスト      [テスト]
        └─ 統合テスト
                ↓
Wave 5 ─┬─ React最適化
        ├─ UI改善                  [UI] ※該当時のみ
        └─ a11y改善
                ↓
Wave 6 ─┬─ コード品質確認
        ├─ 指摘解消確認            [確認]
        └─ 新規問題検出
                ↓
まとめ → FIX-REPORT.md
```

---

## 注意事項

- Critical/Highは必ず修正を試みる
- Mediumは時間があれば修正
- Lowはデフォルトでスキップ（`--include-low` で含める）
- 自動修正が難しい項目は「残作業」としてレポートに記載
- 修正後は必ずテストを実行して確認すること
- **各修正は個別コミットされる**（後でrevertしやすい）
- コミットメッセージには指摘IDが含まれる（追跡性向上）
- `--no-commit` フラグで自動コミットを無効化可能

## 使用例

```bash
# 最新のレビュー結果を元に修正（各修正ごとにコミット）
/fix-review

# 特定のレビュー結果を指定
/fix-review zzz/review-feature-auth-20241217-1430

# 自動コミットを無効化（まとめてコミットしたい場合）
/fix-review --no-commit

# Low優先度も含めて修正
/fix-review --include-low
```
