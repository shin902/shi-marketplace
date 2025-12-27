---
allowed-tools: Task, Bash, Read, Write, Edit, Grep, Glob
description: バグ修正を行うコマンド。仕様とログから範囲を絞り込み、過去の類似例を参照して修正する
---

# /fix コマンド

引数: $ARGUMENTS - バグの内容

## 実行フロー

### 1. ブランチ作成

```bash
new_branch="fix/[バグ内容から生成]"
git checkout -b "$new_branch"
```

### 2. ユーザーに確認

以下を質問してください：
- **期待する動作**: 本来どう動くべきか？
- **実際の動作**: 実際にどうなったか？
- **エラーログ**: ログやエラーメッセージはあるか？

### 3. ログ解析（あれば）

エラーログがある場合：
```
Use the Explore subagent to analyze logs.

Tasks:
1. Locate log files
2. Find error messages
3. Check logs before the error (what succeeded?)
4. Narrow down the problem area
```

ログがない場合：
- 再現手順から該当コードを推測
- エラーメッセージでgrep検索
- 過去の類似バグ探索へ進む

### 4. 仕様確認

Exploreサブエージェントで`openspec/specs/`から関連仕様を読む：
```
Use the Explore subagent to find specifications.

Search: openspec/specs/
Goal: Find how this feature should work (expected behavior)
```

仕様書の読み方は`spec-format`スキルを参照。

### 5. 過去のバグ探索

Exploreサブエージェントで`openspec/bugs/fixed/`から類似例を探す：
```
Use the Explore subagent to search for similar bugs.

Search: openspec/bugs/fixed/
Tasks:
1. Check filenames for relevance
2. Read similar bug reports
3. Return: 既知 or 新規
```

### 6. 計画立案

**既知の場合**: 過去の修正例を参考に実装へ

**新規の場合**:
```
Use the Explore subagent to investigate code.
Then use the Plan subagent to create a fix plan.
```

### 7. 実装

コード修正 → テスト実行 → 最大3回まで自動修正

### 8. ドキュメント作成

`openspec/bugs/fixed/[日付]-[バグ名].md`に記録。
形式は`bugfix`スキルを参照。

### 9. 完了報告

```
バグ修正完了:
- ブランチ: fix/[名前]
- 修正内容: [概要]
- テスト: [結果]
- ドキュメント: openspec/bugs/fixed/[ファイル名]
```
