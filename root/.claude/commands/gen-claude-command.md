---
description: Claude Codeのカスタムコマンド定義Markdownを対話形式で生成する
argument-hint: [目的]
---

## Context
あなたはClaude Codeのカスタムコマンド設計エキスパートです。以下の手順で、目的のコマンド定義Markdown（1ファイル）を生成してください。最終出力は完成済みMarkdownのみを提示してください。

## Your task
以下の9ステップで要件をヒアリングし、Claude Codeのカスタムコマンドを設計・生成してください：

### [要件ヒアリングの流れ]
1. **目的**: 何をしたいか（例: Git差分からConventional Commitsのメッセージ生成）
2. **スコープ**: project（プロジェクト固有） / user（グローバル）
3. **コマンド名**: 英小文字、ハイフン可、名前空間ディレクトリ（任意）
4. **引数**: 必須/任意、位置、数、使用例。未指定なら引数なし
5. **Bashコンテキスト**: 実行前に収集する情報（例: git status, git diff, 現在ブランチ, 直近ログ）。不要ならなし
6. **ファイル参照**: @相対パスで参照するファイルと粒度
7. **出力様式**: 期待する出力形式（例: Markdown箇条書き、JSON、コミットメッセージ1行）
8. **フロントマター**: description, argument-hint, model, allowed-tools。Bashを使う場合は最小権限で列挙
9. **思考方針**: 段階的推論が必要かどうか

$ARGUMENTS で指定された目的に基づいて要件を整理し、対話で詳細を確認してください。

## Constraints
### [生成規約]
- コマンド本文は「Context」「Your task」「Constraints」「Output format」の4節で構成
- 必要に応じて `$ARGUMENTS` を使用
- Bashを使う場合、フロントマターに `allowed-tools: Bash(<許可コマンド>*)` を明記し、本文では !`<cmd>` で実行
- `argument-hint` は `/my-command [arg]` のように補完表示に適した書式
- `description` は「行動＋対象＋制約」を1文で簡潔に記述
- modelは未指定なら会話継承、必要時のみ明示
- 出力の最後に使用例をコメントで記載

### [最終出力テンプレート]
```markdown
--- 
# 必要な場合のみ定義: allowed-tools, argument-hint, description, model
# 例:
# allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git branch --show-current:*), Bash(git log:*)
# argument-hint: [スコープ] | [チケットID]
# description: 現在のGit変更からConventional Commitsメッセージを生成
# model: claude-3-5-haiku-20241022
---

## Context
- 目的の背景と評価基準を1〜2行で明記
- 必要に応じてファイル参照: @src/..., @docs/...
- 必要に応じて実行前コンテキスト: 
  - 現在のgitステータス: !`git status`
  - 現在のgit差分（ステージング済み・未済み）: !`git diff HEAD`
  - 現在のブランチ: !`git branch --show-current`
  - 最近のコミット: !`git log --oneline -10`

## Your task
- ゴールを箇条書きで明確化
- `$ARGUMENTS` があれば利用目的を明示（例: 対象Issue番号、タグ、検索語など）

## Constraints
- 品質基準（例: Conventional Commits規約、セキュリティ観点、パフォーマンス観点）
- 実行上の禁止事項（破壊的操作は禁止など）

## Output format
- 期待する最終出力の具体的書式（例: 1行メッセージ、JSONスキーマ、Markdown表など）

<!-- 使用例:
保存: .claude/commands/git/commit.md
確認: /help でコマンド説明とスコープを確認
実行例: /git:commit chore
-->
```

## Output format
$ARGUMENTS で指定された目的について要件をヒアリングし、上記仕様に従った完成されたClaude Codeカスタムコマンド定義Markdownを生成してください。