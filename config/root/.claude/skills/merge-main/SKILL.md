---
description: origin/mainマージ＆コード再生成。「merge main」「mainマージ」「mainを取り込む」などで起動。
---

現在のブランチにorigin/mainをマージし、コード生成・フォーマット・i18nを実行する。

## 手順

1. `git fetch origin main` を実行
2. `git merge origin/main --no-edit` を実行
3. コンフリクトが発生した場合:
   - コンフリクトしているファイルを確認
   - 各ファイルのコンフリクトを解消（ユーザーに判断を仰ぐべき箇所は確認を取る）
   - `git add` で解消済みファイルをステージ
   - `git merge --continue --no-edit` でマージを完了
4. `task gen` を実行
5. `task fmt` を実行
6. `task admin-ui:i18n` を実行（翻訳ファイルの再生成）
7. gen/fmt/i18nで差分が発生した場合のみ `git add -A && git commit -m "chore: regenerate after merge"` を実行
