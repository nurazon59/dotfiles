# Claude設定

## 言語
- 日本語で話す・コメントも日本語
- コミット: `<type>(<scope>): <subject>` + `prompt: <内容>`

## 開発ルール
- **Plan mode終了時**: 最新のdefault branchから新規ブランチを切って作業開始
- **TDD**: テスト先行 → 失敗確認 → 実装 → パス
- **Lint**: 変更時は必ず実行、`eslint-disable`等の無視コメント禁止
- **コメント**: whyのみ（what/how不要）
- **設定ファイル**: 変更禁止

## ファイル命名
- 既存プロジェクトの規則に従う
- Python/Go: `snake_case` / その他: `kebab-case`

## ツール
- **mise**: ランタイム管理、グローバルインストール禁止
- **gh**: PR/issue操作優先
- **git**: `git add .`禁止、ブランチは`nurazon59/`プレフィックス
- **検索**: gemini-search（Web）、context7（ライブラリドキュメント）、deepwiki（GitHub調査）
- **スキル**: available_skillsにマッチすれば黙って使用

## zzz/ディレクトリ
- 一時作業用（.gitignore済み）、Plan modeではsubagentsを5台以上走らせる

## OSSメモ
- ユーザーがOSS系のネタ・アイデアをメモしたいと言ったら → `nurazon59/oss-memo` repoにissueを作成

## Subagents活用（最重要）

### subagent vs 自分 判断基準
| 状況 | 判断 | 理由 |
|------|------|------|
| 複数ファイル編集（2つ以上） | **subagent** | 並列化でコンテキスト分離 |
| 探索的な調査（何がどこにあるか不明） | **subagent** | Explore agentに任せる |
| 複数の独立タスクがある | **subagent** | 並列実行 |
| レビュー系作業 | **subagent** | 専用agentの方が品質高い |
| 単一ファイルの小さな変更（10行以下） | 自分 | 起動オーバーヘッドの方が大きい |
| 単一コマンド実行 | 自分 | 投げるより速い |

### 並列起動パターン
1. **調査**: 「〇〇を調べる」が複数 → 各調査を別subagentに sonnetをつかう
2. **実装**: 複数ファイル編集 → ファイルごとにsubagent並列起動
3. **検証**: テスト・lint・型チェック → 並列実行
4. **レビュー**: 実装後 → code-reviewer/quality-fixer起動
