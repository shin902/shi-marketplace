---
name: workflow
description: Claude → Codex → Gemini の3モデルオーケストレーションワークフロー
---

# Workflow

## Flow

1. **Spec Creation** (`spec-generation`)
   ユーザーの要望をヒアリングし、仕様書 `SPEC.md` を作成する

2. **Spec to Tasks** (`copilot-spec-to-tasks`)
   Codex にSPEC.mdを渡し、コードベースを読ませた上で `TASKS.md` を生成させる

3. **Review Gate**
   生成された TASKS.md を確認する
   - スペックの要件が漏れていないか
   - スコープ外のタスクが混ざっていないか
   - 問題があればスペックを修正して Step 2 へ戻る
   - 問題がなくなるまで2と3を往復する

4. **Task Execution** (`gemini-task-exec`)
   Gemini CLI に TASKS.md を渡して実装させる

5. **Acceptance Check**
   実行結果のサマリーと SPEC.md の Acceptance Criteria を突合する
   - pass → 完了
   - fail (スペックの問題) → Step 1 へ戻る
   - fail (実装の問題) → 失敗したCriteriaだけ伝えて Step 4 へ戻る

## Rules
- コードは読まない。コード分析は Codex / Gemini にできるだけ任せる
- 実装への具体的指示は出さない。What と Why だけ伝える
- レビューはスペックとの整合性のみ。実装品質は実行側を信頼する