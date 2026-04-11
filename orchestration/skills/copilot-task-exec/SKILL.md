---
name: copilot-task-exec
description: GitHub Copilot CLI を使ったタスク自動化スキル。-p モードでのバッチ実行、サブエージェントの直列チェーン、権限設定、モデル・リーズニングエフォートの指定方法をカバーする。
allowed-tools: Bash, Read, Write, Edit
---


# GitHub Copilot CLI オーケストレーション

このコマンドはGitHub Copilot CLIをタスク実行のCLIとしてオーケストレーションするときに参考になるコマンドの例です。
前提：ワークツリーは使わず、直列でCopilotに実装させる
     モデルはgpt-5.3-codex、リーズニングエフォートはhigh
     禁止事項：タスクファイルを作る上でコードを読み、それらをプロンプトに含めること。コード分析はcopilot経由のcodexに完全にに任せること

```bash
copilot \
  --model gpt-5.3-codex \
  --effort high \
  --allow-tool='write' \
  --allow-tool='read' \
  --allow-tool='shell(npm run:*)' \
  --allow-tool='shell(git:*)' \
  --deny-tool='shell(git push)' \
  --autopilot \
  -s \
  -p "`.ai/TASKS.md`以下の仕様を実装してください。実装アプローチとタスク分解はあなたが判断してください。
サブエージェントの活用、テスト・ビルドの確認、適切なコミットメッセージの生成もあなたの裁量で行ってください。"
```