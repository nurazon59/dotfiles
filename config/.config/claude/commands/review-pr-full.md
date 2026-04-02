# PRフルレビューコマンド（全部のせ・Wave方式）

18 agentを3並列×6 Waveで実行し、各観点から徹底的にレビューを実行する。

## 実行手順

### Phase 0: 事前準備

1. ブランチ情報を取得
   ```bash
   BRANCH=$(git branch --show-current)
   DATE=$(date +%Y%m%d-%H%M)
   ```

2. 差分を確認
   ```bash
   git diff main...HEAD --stat
   git diff main...HEAD
   ```

3. 変更ファイルのリストを取得し、言語・フレームワークを判定
   - TypeScript/JavaScript → typescript-pro, react-frontend-specialist
   - Python → python-pro
   - Go → golang-pro
   - Rust → rust-pro
   - UI変更あり → ui-design-specialist, playwright-browser-verifier, ui-visual-validator

4. `zzz/review-{ブランチ名}-{日付}/` ディレクトリを作成

---

## Phase 1: Wave方式レビュー（3並列 × 6 Wave）

各Waveで3つのagentを**並列実行**し、完了を待ってから次のWaveへ進む。
各agentは `zzz/review-{ブランチ名}-{日付}/` 配下に個別mdファイルを出力する。

---

### 🌊 Wave 1: 基礎分析（コード全体像の把握）

| # | Agent | 出力ファイル | 観点 |
|---|-------|-------------|------|
| 1 | `pr-review-toolkit:code-reviewer` | `01-code-quality.md` | 規約、ベストプラクティス、可読性、命名 |
| 2 | `feature-dev:code-explorer` | `02-codebase-impact.md` | 既存コードへの影響、実行パス、依存関係 |
| 3 | 言語特化agent（動的選択）| `03-language-specific.md` | 言語固有のイディオム、最新機能活用 |

> 言語特化: TypeScript→`typescript-pro` / Python→`python-pro` / Go→`golang-pro` / Rust→`rust-pro`

---

### 🌊 Wave 2: 品質分析（コード品質の深掘り）

| # | Agent | 出力ファイル | 観点 |
|---|-------|-------------|------|
| 4 | `pr-review-toolkit:code-simplifier` | `04-simplification.md` | 複雑なコードの簡素化、リファクタリング候補 |
| 5 | `pr-review-toolkit:comment-analyzer` | `05-comments.md` | コメントの正確性、長期保守性、技術的負債 |
| 6 | `pr-review-toolkit:type-design-analyzer` | `06-type-design.md` | 型設計、カプセル化、不変条件 |

---

### 🌊 Wave 3: 堅牢性分析（エラー・テスト・セキュリティ）

| # | Agent | 出力ファイル | 観点 |
|---|-------|-------------|------|
| 7 | `pr-review-toolkit:silent-failure-hunter` | `07-error-handling.md` | サイレント失敗、握りつぶし、不適切なcatch |
| 8 | `pr-review-toolkit:pr-test-analyzer` | `08-test-coverage.md` | カバレッジ、エッジケース、テストの妥当性 |
| 9 | `general-purpose`（セキュリティ）| `09-security.md` | XSS、CSRF、SQLi、認証認可、機密情報 |

---

### 🌊 Wave 4: アーキテクチャ・パフォーマンス分析

| # | Agent | 出力ファイル | 観点 |
|---|-------|-------------|------|
| 10 | `feature-dev:code-architect` | `10-architecture.md` | 設計パターン、責任分離、依存関係、スケーラビリティ |
| 11 | `general-purpose`（パフォーマンス）| `11-performance.md` | メモリリーク、N+1、バンドルサイズ、重い処理 |
| 12 | `general-purpose`（ドキュメント）| `12-documentation.md` | README更新、API doc整合性、破壊的変更 |

---

### 🌊 Wave 5: UI/フロントエンド分析（UI変更時のみ）

| # | Agent | 出力ファイル | 観点 |
|---|-------|-------------|------|
| 13 | `react-frontend-specialist` | `13-react-optimization.md` | 再レンダリング、hooks最適化、state管理 |
| 14 | `ui-design-specialist` | `14-ui-design.md` | レイアウト、スペーシング、視覚的階層 |
| 15 | `accessibility-compliance:ui-visual-validator` | `15-accessibility.md` | ARIA、キーボード、スクリーンリーダー、コントラスト |

> ⚠️ UI変更がない場合はこのWaveをスキップ

---

### 🌊 Wave 6: 最終確認・集約

| # | Agent | 出力ファイル | 観点 |
|---|-------|-------------|------|
| 16 | `playwright-browser-verifier`（UI変更時）| `16-browser-test.md` | 実ブラウザ動作確認、ユーザーフロー |
| 17 | `comment-cleaner` | `17-comment-cleanup.md` | 不要なコメント、コメントアウトコード |
| 18 | `general-purpose`（まとめ）| `FINAL-REPORT.md` | 全結果の集約・重要度分類 |

> Wave 6のまとめagentは、Wave 1-5の全出力ファイルを読み込んで最終レポートを生成する

---

## Wave実行フロー図

```
Wave 1 ─┬─ code-reviewer
        ├─ code-explorer        → 完了待ち
        └─ language-specific
                ↓
Wave 2 ─┬─ code-simplifier
        ├─ comment-analyzer     → 完了待ち
        └─ type-design-analyzer
                ↓
Wave 3 ─┬─ silent-failure-hunter
        ├─ pr-test-analyzer     → 完了待ち
        └─ security
                ↓
Wave 4 ─┬─ code-architect
        ├─ performance          → 完了待ち
        └─ documentation
                ↓
Wave 5 ─┬─ react-frontend       (UI変更時のみ)
        ├─ ui-design            → 完了待ち
        └─ accessibility
                ↓
Wave 6 ─┬─ playwright           (UI変更時のみ)
        ├─ comment-cleaner      → 完了待ち
        └─ まとめagent → FINAL-REPORT.md
```

---

## Phase 2: 結果集約（Wave 6のまとめagent）

Wave 6のまとめagentが以下を実行:

#### Agent: general-purpose（結果集約）
- **入力**: `zzz/review-{ブランチ名}-{日付}/` 配下の全md
- **出力**: `zzz/review-{ブランチ名}-{日付}/FINAL-REPORT.md`
- **タスク**:
  1. 全mdファイルを読み込む
  2. 重要度別に分類（Critical / High / Medium / Low）
  3. 重複を排除・統合
  4. 以下のフォーマットで最終レポート生成

---

## 最終レポートフォーマット

```markdown
# PRフルレビュー最終レポート

**ブランチ**: {ブランチ名}
**レビュー日時**: {日時}
**変更ファイル数**: {数}
**変更行数**: +{追加} / -{削除}
**使用Agent数**: {数}

---

## エグゼクティブサマリー

{変更内容の3行サマリー}

---

## 🔴 Critical（即座に修正が必要）

| # | 観点 | 問題 | ファイル | 推奨対応 |
|---|------|------|----------|----------|
| 1 | セキュリティ | ... | ... | ... |

---

## 🟠 High（リリース前に修正すべき）

| # | 観点 | 問題 | ファイル | 推奨対応 |
|---|------|------|----------|----------|

---

## 🟡 Medium（可能であれば修正）

| # | 観点 | 問題 | ファイル | 推奨対応 |
|---|------|------|----------|----------|

---

## 🟢 Low（改善提案）

| # | 観点 | 問題 | ファイル | 推奨対応 |
|---|------|------|----------|----------|

---

## ✅ 良い点

- {良い実装のリスト}

---

## 各観点詳細

<details>
<summary>1. コード品質</summary>

{01-code-quality.md の内容要約}

</details>

<details>
<summary>2. 簡素化提案</summary>

{02-simplification.md の内容要約}

</details>

... (全17観点)

---

## 推奨アクションリスト

### 必須（マージ前）
- [ ] {Critical/Highの対応}

### 推奨（可能なら）
- [ ] {Medium/Lowの対応}

---

## 総合評価

**スコア**: {A/B/C/D/F}

{総合的なコメント}
```

---

## 注意事項

- レビューには10-15分程度かかる
- 17 agentsを並列起動するため負荷が高い
- UI変更がない場合、Agent 10-13は自動スキップ
- 全結果は `zzz/` に保存（Git管理外）
- まとめagentは全agentの完了を待ってから実行

## 使用例

```
/review-pr-full
```
