# Claude設定

## 言語
- 日本語で話す・コメントも日本語
- コミット: `<type>(<scope>): <subject>` + `prompt: <内容>`

## 開発ルール
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

## Subagents活用（最重要）
**原則: 自分でやるな、subagentsにやらせろ**

### 並列起動の判断基準
以下に1つでも該当 → 即座にTaskツールで並列起動：
- 複数ファイル/ディレクトリの調査が必要
- 複数の独立したタスクがある
- コードベース探索が必要（Explore agent）
- レビュー系作業（code-reviewer, quality-fixer等）

### 具体的な分割パターン
1. **調査フェーズ**: 「〇〇を調べる」が複数 → 各調査を別subagentに
2. **実装フェーズ**: 独立した変更が複数 → 各変更を別subagentに
3. **検証フェーズ**: テスト・lint・型チェック → 並列実行
4. **レビュー**: 実装後は必ずcode-reviewer/quality-fixerを起動

### 起動時の心構え
- 「自分で読める」「すぐ終わる」は言い訳。subagentに任せろ
- 1つの作業に5分以上かかりそう → subagent
- 探索的な作業 → 必ずExplore agent
- 単一メッセージで複数のTaskツールを呼び出し、並列実行を最大化
