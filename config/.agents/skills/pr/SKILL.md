---
description: テスト実行→変更サマリ付きPR作成→セルフレビュー→URL報告を行う。「PR作って」「PR作成」「PRを出して」「create PR」などで起動。PRの内容レビューにはpr-review-workflowを使うこと。
---

1. すべてのテストを実行して通ることを確認
2. 変更のサマリー付きでPRを作成
3. サブエージェントを起動してdiffのバグとスタイルをレビュー
4. CI失敗時にforce-mergeしない
5. 完了後にPR URLを報告
