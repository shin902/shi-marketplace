---
name: spec-to-tasks-with-codex
description: 仕様書を読み、コードベースを分析し、実行可能なタスクリストを生成する
---

# Spec to Tasks

## Input
仕様書（スペック）が提供される。

## Process

1. その仕様書をCodexにそのまま渡し、タスクを生成させる
2. ユーザーに報告。内容を噛み砕いて、スペックをちゃんと満たしてるか・やりすぎなところはないかを吟味する（Claudeはコードを見ない）


仕様書をCodex CLIに読み込ませ、タスクリストを生成させてください
Out of Scopeや、実装しなくていいものが含まれていた場合は、それを含めて再度codexに説明してください。
質問などがあったら適宜ユーザーにすること

## コマンド実行方法

### initial task list generation
- モデルの指定などはこれが最適なので変えないこと
- このBashコマンドはバックグラウンドタスクとして作成すること
```bash
codex exec -m gpt-5.4 "以下の仕様書を読み、コードベース全体を把握した上で、TASKS.md を生成してください。

仕様書: [SPEC.mdのパス]
TASKS.md を以下の形式で生成する。

TASKS.md のフォーマット:
# Tasks
## Summary
[仕様の1行要約]
## Tasks
### 1. [タスク名]
- Why: なぜ必要か（Acceptance Criteriaとの対応）
- What: 何を変更するか
- Done when: 完了条件

---

ルール:
- How（実装方法）は書かない。実装方法は実行時に判断する
- タスクは最大5つ。細かくしすぎない
- 既存のコード規約・パターンに従う前提で書く
- テストとビルド確認は各タスクに暗黙的に含まれるため個別タスクにしない
- TASKS.md をファイルとして書き出すこと"
- 保存場所はカウントディレクトリの`.ai/`
```

# updated task list generation
- resume --lastオプションを付けないと前回の文脈が落ちるので注意
```bash
codex exec resume --last -m gpt-5.3-codex "[修正指示をここに書く]
TASKS.md を更新してください。"
```


