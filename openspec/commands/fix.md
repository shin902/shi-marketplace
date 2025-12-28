---
allowed-tools: Task, Bash, Read, Write, Edit, Grep, Glob
description: バグ修正。仕様とログから範囲を絞り込み、修正する
---

# バグ修正: $ARGUMENTS

## ゴール

バグを修正し、ドキュメント化する。

## 参照

- **デバッグ原則**: `debugging`スキル
- **仕様書**: `openspec/specs/`
- **過去のバグ**: `openspec/bugs/fixed/`
- **ログ記録**: `logging`スキル
- **ドキュメント形式**: `bugfix`スキル

## 制約

- ブランチ: `fix/[バグ名]`
- テスト: 最大3回まで自動修正
- 記録: `openspec/bugs/fixed/[日付]-[バグ名].md`
