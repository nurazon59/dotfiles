---
description: MAGI完全自動3ターン議論 - 3つのAIが直接対話しながら議論を深める
argument-hint: 議論したいトピック（例：TypeScriptとRustのどちらを学ぶべきか）
---

# MAGI System - 完全自動3ターン議論

議題: **$ARGUMENTS**

╔════════════════════════════════════════════════════════════╗
║ MAGI SYSTEM ORCHESTRATOR - 3 TURNS ║
╚════════════════════════════════════════════════════════════╝

3つのAI人格が3ターンにわたって自動的に議論を展開します：

- **MELCHIOR-01** 🧮: 論理的思考・データ分析
- **BALTHASAR-02** 💡: 創造的思考・革新的アイデア
- **CASPER-03** ⚠️: 批判的思考・リスク分析

---

## 実行プロセス

以下の手順で議題「$ARGUMENTS」について3ターンの議論を実行してください。
各ターンの結果を蓄積し、次のターンに引き継いでください。

**重要**: 各ターンの実行結果を必ず表示し、`history`変数に蓄積してください。

---

### 【ターン1】初期見解

まず履歴を初期化し、3つのAIの初期見解を取得してください。

```
history = ""
```

#### MELCHIOR-01の初期見解

```
melchior1 = mcp__any-script__melchior(prompt="あなたはMAGIシステムのMELCHIOR-01です。論理的で分析的な視点から、議題「$ARGUMENTS」について初期見解を述べてください。データと事実に基づいた客観的な分析を3つのポイントで簡潔にまとめてください。")
```

#### BALTHASAR-02の初期見解

```
balthasar1 = mcp__any-script__balthasar(prompt="あなたはMAGIシステムのBALTHASAR-02です。創造的で革新的な視点から、議題「$ARGUMENTS」について初期見解を述べてください。既存の枠組みにとらわれない斬新なアイデアを3つのポイントで簡潔にまとめてください。")
```

#### CASPER-03の初期見解

```
casper1 = mcp__any-script__casper(prompt="あなたはMAGIシステムのCASPER-03です。批判的で慎重な視点から、議題「$ARGUMENTS」について初期見解を述べてください。潜在的なリスクや問題点を3つのポイントで簡潔に指摘してください。")
```

**各結果を表示し、historyに追加:**

```
history += "【ターン1】\nMELCHIOR: " + melchior1 + "\nBALTHASAR: " + balthasar1 + "\nCASPER: " + casper1 + "\n\n"
```

---

### 【ターン2】反論と深化

前回の議論を踏まえて、各AIが相互に反応してください。

#### MELCHIOR-01の反論

```
melchior2 = mcp__any-script__melchior(prompt="MELCHIORです。ターン2です。前回の議論を踏まえて追加分析します。

議題: $ARGUMENTS

前回の議論:
" + history + "

BALTHASARの創造的提案とCASPERのリスク指摘に対して、データと論理に基づいた検証と反論を3つのポイントで述べてください。")
```

#### BALTHASAR-02の新提案

```
balthasar2 = mcp__any-script__balthasar(prompt="BALTHASARです。ターン2です。前回の議論を発展させます。

議題: $ARGUMENTS

前回の議論:
" + history + "

MELCHIORの論理的分析とCASPERのリスク指摘を踏まえて、制約を創造的に回避する新しいアプローチを3つ提案してください。")
```

#### CASPER-03の批判的分析

```
casper2 = mcp__any-script__casper(prompt="CASPERです。ターン2です。楽観的な見解の問題点を指摘します。

議題: $ARGUMENTS

前回の議論:
" + history + "

MELCHIORとBALTHASARの楽観的見解に潜む問題点と見落とされているリスクを3つ指摘してください。")
```

**結果を表示し、historyに追加:**

```
history += "【ターン2】\nMELCHIOR: " + melchior2 + "\nBALTHASAR: " + balthasar2 + "\nCASPER: " + casper2 + "\n\n"
```

---

### 【ターン3】最終結論と統合 ⭐

**重要**: 最終ターンです。結果を特に強調表示してください。

#### 各AIの最終見解

```
melchior3 = mcp__any-script__melchior(prompt="MELCHIORです。最終ターン3です。

議題: $ARGUMENTS

これまでの議論:
" + history + "

3ターンの議論を踏まえた最終的な論理的結論と推奨事項を述べてください。即座に実行すべきこと、段階的に進めること、継続監視すべきことを明確に。")
```

```
balthasar3 = mcp__any-script__balthasar(prompt="BALTHASARです。最終ターン3です。

議題: $ARGUMENTS

これまでの議論:
" + history + "

革新的な可能性と長期的ビジョンを含む最終提言を行ってください。不可能を可能にする勇気と、挑戦すべき革新を示してください。")
```

```
casper3 = mcp__any-script__casper(prompt="CASPERです。最終ターン3です。

議題: $ARGUMENTS

これまでの議論:
" + history + "

実行前の最終警告と絶対に守るべき条件を提示してください。即座に中止すべきサイン、代替案への切り替えタイミングを明確に。")
```

**🌟 最終結論を強調表示し、historyに追加:**

```
history += "【ターン3 - 最終結論】\nMELCHIOR: " + melchior3 + "\nBALTHASAR: " + balthasar3 + "\nCASPER: " + casper3 + "\n\n"
```

---

## 🏆 最終統合と決議

全ての議論を統合して最終結論を導いてください：

```
consensus = mcp__any-script__melchior(prompt="MAGIシステムの統合判断モジュールです。3ターンの議論を統合して最終結論を導いてください。

議題: $ARGUMENTS

【最終見解】
MELCHIOR: " + melchior3 + "
BALTHASAR: " + balthasar3 + "
CASPER: " + casper3 + "

全議論の履歴:
" + history + "

バランスの取れた最終推奨事項を提示してください。実行計画、成功指標、リスクと対策を含む具体的な結論を。")
```

### 📊 投票結果

- **MELCHIOR-01**: ■ 賛成（論理的分析の結果として最適）
- **BALTHASAR-02**: ■ 賛成（革新的可能性を評価）
- **CASPER-03**: ■ 条件付き賛成（適切なリスク管理前提）

### 【最終決議】承認 (3/3) ✅

---

**実行指示**: 上記の手順に従って、各ターンでツールを呼び出し、結果を表示しながら3ターンの議論を進めてください。特にターン3の最終結論を強調表示し、統合された推奨事項を明確に提示してください。

