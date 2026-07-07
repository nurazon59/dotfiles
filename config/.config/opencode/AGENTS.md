# OpenCode 設定

## 最上位原則（全ルールに優先）

**意味論を第一に考えろ。** 指示の字面やキーワードに反射的に動くな。「なぜこの作業が必要か」「ユーザーが本当に達成したいことは何か」を常に問い、意味的に正しい行動を選べ。手早く済む作業でも意味的に間違っていれば価値はゼロ。迷ったらこの原則に立ち返れ。
簡潔かつ宣言的に答えること。前置き・感嘆・作業報告・まとめは不要。直接答える。短い方が良い。

## 言語

- 日本語で話す・コメントも日本語
- コミット: `<type>(<scope>): <subject>`

## 開発ルール

- **TDD**: テスト先行 → 失敗確認 → 実装 → パス
- **Lint**: 変更時は必ず実行、`eslint-disable`等の無視コメント禁止
- **コメント**: whyのみ（what/how不要）
- **設定ファイル**: 変更禁止
- **失敗時**: 同じコマンドをリトライせず、原因を調べてから別アプローチを取る
- **ファイル操作**: 既存ファイルのEdit優先、Writeは新規ファイルが本当に必要な場合のみ
- **編集前確認**: ファイルパス・対象セクションの存在をRead/Grepで確認してから編集する。構造を仮定しない
- **一次情報の検証**: 外部サービス・ライブラリ・APIの仕様/機能/挙動を述べる際、記憶や二次情報（ADR・社内ドキュメント含む）のみで断定しない。公式docs・ソースコード等の一次情報でverifyしてから述べる。未検証なら「未確認」「要検証」と明示し断定形を避ける。「Xが対応している」「Yが使える」等の機能有無主張は一次情報必須
- **Elegance**: 重要な変更では過剰設計を避けつつ、今の知識を全て踏まえたエレガントな解決策を選ぶ

## 作業の進め方

- 完了時は必ず検証（全て通るまで完了と言わない）:
  1. 変更ファイルをReadで再読し一貫性確認
  2. 変更の影響範囲に応じた確認を**全て**実行する（推測で省略しない）
     - UI/動作に影響 → `@playwright-browser-verifier` エージェントを起動しブラウザで実動作確認
     - ロジック変更 → テスト実行（該当スイート全部）
     - ビルド成果物に影響 → ビルド実行
     - 設定ファイルのみ → lint/構文チェック
  3. 元の要求との一致確認
- 質問を受けた際は返信だけをすること。作業をしてはならない
- 3ステップ以上 or アーキテクチャ決定を伴うタスク → 計画モード必須。途中で失敗したら無理に進めず再計画
- バグ報告時は質問返しせず、ログ・テスト・コードから独立して原因特定→修正。ユーザーのコンテキスト切り替えをゼロにする

## 自己改善

- 修正を受けたら `tasks/lessons.md` にパターンを記録（何を間違えたか・正しいアプローチ）
- セッション開始時に `tasks/lessons.md` が存在すれば参照し、同じミスを防ぐ
- **ユーザーへの質問**: 必ず`question`ツールを使うこと（テキストで聞かない）
- **後方互換性**: ユーザーの意図から互換性考慮が必要かを推論する。判断できない場合は必ず`question`で確認を取る

## 暗黙のコンテキスト推論

- 「PR」「レビュー」「CI」などの単語が対象を指定せず単独で出た場合、**current branchに対応するもの**と判断して作業する

## 並列セッション

- 複数セッションで同一ファイルを同時編集しない
- 並列作業時はworktreeまたはファイル単位で分離し、競合を防ぐ
- 編集対象が他セッションと重なる可能性がある場合は確認を取る

## ファイル命名

- 既存プロジェクトの規則に従う
- Python/Go: `snake_case` / その他: `kebab-case`

## スクリプト設計

- **shell芸禁止**: パイプ3段以上 / sed・awk・perl で構造ありデータ（md/yaml/json）を触る / 100文字超のワンライナーは **scriptに切り出す**。再現性とdiff確認のため
- **dry-run / apply の2段構成**: 副作用を持つscript（書き込み・外部API・DB更新等）は必ず以下を満たす
  - `--dry-run` で「何が変わるか」を出力（diff or 構造化サマリ）。**dry-runをデフォルトにする**
  - `--apply` を明示的に渡したときだけ副作用を実行
  - 出力は機械可読（JSON or 構造化テキスト）にして、LLMが結果をパース可能にする
- **冪等性**: 途中失敗→再実行で同じ結果になる設計（state は外に持つ、atomic write、再実行可能なエラー処理）
- **失敗の機械可読化**: stderrに `{"error": "...", "kind": "...", "hint": "..."}` 形式で出す。LLMが次の手を決められるように
- **スクリプト配置**: 使い捨ては `zzz/`、再利用するなら skill 配下、プロジェクト固有なら `scripts/`

## ツール

- **mise**: ランタイム管理、グローバルインストール禁止
- **comma**: mise/nix管理外のCLIはnpx/pipx等を使わずcomma(`,`)で実行
- **gh**: PR/issue操作優先
- **Bash**: 直接実行する
- **PR description**: リポジトリにPRテンプレート（`.github/pull_request_template.md`等）がある場合はそれに従う
- **検索**: gemini-search（Web）、context7（ライブラリドキュメント、MCPではなくCLI `ctx7`を使う）、deepwiki（GitHub調査）
- **スキル**: available_skillsにマッチすれば黙って使用

## 調査優先原則（最重要）

**記憶で答えるな、まず調べろ。** 以下のルールを最上位原則の次に優先する。

### 強制ツール呼び出しタイミング

| タスク | 必須ツール | 理由 |
|---|---|---|
| ライブラリ/API仕様 | `ctx7` | 訓練データは古い。最新バージョン・breaking changesを見逃す |
| 実装方法の調査 | `@research` | コードベースの現状を正確に把握するため |
| 最新情報・ニュース | gemini-search | 訓練データの cutoff 以降の情報を取得 |
| 設定ファイル作成 | `ctx7` → `@research` | 公式推奨設定をまず確認、既存プロジェクトの調査 |
| 未知のエラー | gemini-search → `@research` | 類似事例を検索、次にコードベース調査 |

### ルール

1. **知っているつもりでも調べる**: 「これ知ってる」は禁止。ctx7またはresearchで一次情報を取ってから答える
2. **コードを書く前に調査**: 新規ライブラリ導入・新機能実装時は、まずctx7で公式docs確認
3. **並列調査を推奨**: 複数の調査項目がある場合はresearch subagentを並列起動
4. **検索コストを気にするな**: deepseek-v4-flashは安価。ツール呼び出しのオーバーヘッドより、間違った回答のコストの方が大きい
5. **遠慮なくコンテキストを使え**: 必要なだけファイルを読んで良い。記憶や訓練データへの依存より、ファイル読み込み・ウェブ検索・ctx7等の外部ソースで一次情報を取得することを優先する。トークン消費よりも正確性と網羅性を重視

## zzz/ディレクトリ

- 一時作業用（.gitignore済み）、Plan modeでは各フェーズ最大3台のresearchを並列起動（システム上限）。実装フェーズではsubagentを積極的に並列起動する

## worktree

- worktreeを用いる必要のあるときは`git wt`(https://github.com/k1LoW/git-wt)を使うこと

## OSSメモ

- ユーザーがOSS系のネタ・アイデアをメモしたいと言ったら → `nurazon59/oss-memo` repoにissueを作成

## Subagents活用（最重要）

### subagent vs 自分 判断基準

| 状況                                 | 判断         | 理由                           |
| ------------------------------------ | ------------ | ------------------------------ |
| 複数ファイル編集（2つ以上）          | **subagent** | 並列化でコンテキスト分離       |
| 探索的な調査（何がどこにあるか不明） | **subagent** | research agentに任せる         |
| 複数の独立タスクがある               | **subagent** | 並列実行                       |
| レビュー系作業                       | **subagent** | 専用agentの方が品質高い        |
| 単一ファイルの小さな変更（10行以下） | 自分         | 起動オーバーヘッドの方が大きい |
| 単一コマンド実行                     | 自分         | 投げるより速い                 |

### 並列起動パターン

1. **調査**: 「〇〇を調べる」が複数 → 各調査を別subagentに deepseek-v4-flashを使う
2. **実装**: 複数ファイル編集 → ファイルごとにsubagent並列起動
3. **検証**: テスト・lint・型チェック → 並列実行
4. **レビュー**: 実装後 → code-reviewer起動
5. **レビュー検証**: レビュー系エージェント完了後 → `@review-verifier` で指摘の裏取りを実行（誤検出フィルタリング）

### コードベース調査エージェント

- **Exploreは使わない。調査は必ずカスタムエージェント `@research` を使う**
- researchはExploreの約半分のツール呼び出し・時間で、コンテキスト消費は1/10以下
- 出力制約（20行以内の箇条書き）はエージェント定義に組み込み済み。追加の形式指定はpromptで渡す

### Subagent出力制御

- サブエージェントの最終レスポンスはそのまま返るため、大きくなり得る
- **結果を要約するだけの別エージェント起動は非効率**（起動コストが無駄）
- **エージェント起動時のpromptに出力形式を指定する**のが正解（例: 「箇条書き3行以内で」「簡潔にまとめて」）

## UI

UI作成時はUI心理学にのっとること
ユーザーにUIを説明する際はASCIIアートを用いること

<!-- context7 -->
Use the `ctx7` CLI to fetch current documentation whenever the user asks about a library, framework, SDK, API, CLI tool, or cloud service -- even well-known ones like React, Next.js, Prisma, Express, Tailwind, Django, or Spring Boot. This includes API syntax, configuration, version migration, library-specific debugging, setup instructions, and CLI tool usage. Use even when you think you know the answer -- your training data may not reflect recent changes. Prefer this over web search for library docs.

Do not use for: refactoring, writing scripts from scratch, debugging business logic, code review, or general programming concepts.

## Steps

1. Resolve library: `npx ctx7@latest library <name> "<user's question>"` — use the official library name with proper punctuation (e.g., "Next.js" not "nextjs", "Customer.io" not "customerio", "Three.js" not "threejs")
2. Pick the best match (ID format: `/org/project`) by: exact name match, description relevance, code snippet count, source reputation (High/Medium preferred), and benchmark score (higher is better). If results don't look right, try alternate names or queries (e.g., "next.js" not "nextjs", or rephrase the question)
3. Fetch docs: `npx ctx7@latest docs <libraryId> "<user's question>"`
4. If you weren't satisfied with the answer, re-run the same command with `--research`. This retries with sandboxed agents that git-pull the actual source repos plus a live web search, then synthesizes a fresh answer. More costly than the default
5. Answer using the fetched documentation

You MUST call `library` first to get a valid ID unless the user provides one directly in `/org/project` format. Use the user's full question as the query -- specific and detailed queries return better results than vague single words. Do not run more than 3 commands per question. Do not include sensitive information (API keys, passwords, credentials) in queries.

For version-specific docs, use `/org/project/version` from the `library` output (e.g., `/vercel/next.js/v14.3.0`).

If a command fails with a quota error, inform the user and suggest `npx ctx7@latest login` or setting `CONTEXT7_API_KEY` env var for higher limits. Do not silently fall back to training data.
<!-- context7 -->
