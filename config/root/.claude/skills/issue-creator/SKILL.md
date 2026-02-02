---
name: issue-creator
description: GitHub issueを作成する。Why/What/How形式で簡潔に記述。「issueを作成」「issue作って」などで起動。
---

# Issue Creator

`gh issue create`でissueを作成する。

## 形式

```markdown
## Why
[1-2文]

## What
[箇条書き]
```

- Howはユーザー指示がある場合のみ追加
- 余分な説明・装飾不要

## 実行

```bash
gh issue create --repo <owner/repo> --title "<タイトル>" --body "<本文>"
```

- リポジトリ指定なし → 現在のリポジトリ
- タイトル50文字以内
