---
description: MAGI完全自動10ターン議論 - AIが自動的に議論を深めていく
argument-hint: 議論したいトピック（例：TypeScriptとRustのどちらを学ぶべきか）
model: opus
---

# MAGI System - 完全自動10ターン議論

議題: **$ARGUMENTS**

╔════════════════════════════════════════════════════════════╗
║           MAGI SYSTEM ORCHESTRATOR - 10 TURNS               ║
╚════════════════════════════════════════════════════════════╝

3つのAI人格が10ターンにわたって自動的に議論を展開します：
- **MELCHIOR-01** 🧮: 論理的思考・データ分析
- **BALTHASAR-02** 💡: 創造的思考・革新的アイデア  
- **CASPER-03** ⚠️: 批判的思考・リスク分析

---

## 実行開始

以下の手順で、議題「$ARGUMENTS」について10ターンの議論を自動実行してください。各ターンで前の結果を引き継ぎながら議論を深めます。

### 【ターン1】初期見解
any-scriptのmagi-discussionツールを使用して、3つのAIの初期見解を取得：

`result1 = mcp__any-script__magi-discussion(topic="$ARGUMENTS", turn=1, history="")`

ターン1の結果を表示し、`history`変数に保存。

### 【ターン2】反論と深化
ターン1の結果を踏まえて、各AIが相互に反応：

`result2 = mcp__any-script__magi-discussion(topic="$ARGUMENTS", turn=2, history=history)`

結果を表示し、`history`に追加。

### 【ターン3】具体的分析
データ分析、創造的解決策、リスク評価を具体化：

`result3 = mcp__any-script__magi-discussion(topic="$ARGUMENTS", turn=3, history=history)`

結果を表示し、`history`に追加。

### 【ターン4】統合的アプローチ
3つの視点を統合し、共通点と相違点を整理：

`result4 = mcp__any-script__magi-discussion(topic="$ARGUMENTS", turn=4, history=history)`

結果を表示し、`history`に追加。

### 【ターン5】中間まとめ
5ターンの議論を総括し、方向性を確認：

`result5 = mcp__any-script__magi-discussion(topic="$ARGUMENTS", turn=5, history=history)`

**中間まとめを強調表示**し、`history`に追加。

### 【ターン6】詳細検討
新たな視点を導入し、さらに深い分析：

`result6 = mcp__any-script__magi-discussion(topic="$ARGUMENTS", turn=6, history=history)`

結果を表示し、`history`に追加。

### 【ターン7】実装計画
具体的な実行計画を各視点から提案：

`result7 = mcp__any-script__magi-discussion(topic="$ARGUMENTS", turn=7, history=history)`

結果を表示し、`history`に追加。

### 【ターン8】コスト効果分析
短期・長期の影響とROIを分析：

`result8 = mcp__any-script__magi-discussion(topic="$ARGUMENTS", turn=8, history=history)`

結果を表示し、`history`に追加。

### 【ターン9】最終評価
各AIの最終的な評価と確信度：

`result9 = mcp__any-script__magi-discussion(topic="$ARGUMENTS", turn=9, history=history)`

結果を表示し、`history`に追加。

### 【ターン10】最終結論と統合
10ターンの議論を統合し、最終決定：

`result10 = mcp__any-script__magi-discussion(topic="$ARGUMENTS", turn=10, history=history)`

**最終結論と投票結果を強調表示**。

---

## 実行指示

上記の10個のmagi-discussionツール呼び出しを順番に実行し、各結果を次のターンの履歴として渡してください。各ターンの実行結果を表示しながら、議論を段階的に深めていってください。

特に重要なポイント：
- 各ターンの結果を必ず表示する
- 前のターンの内容を履歴として次のターンに渡す
- ターン5（中間まとめ）とターン10（最終結論）は特に強調する
- 最後に投票結果と統合された推奨事項を明確に提示する

---

**実行開始**: 今すぐ上記の手順に従って10ターンの議論を開始してください。