---
description: フックに必要なシェルコマンドをセットアップします
allowed-tools: Bash(curl:+), Bash(mkdir:*)
---
```zsh
mkdir -p ~/.claude/scripts
curl -L -o ~/.claude/scripts/commit-and-summarize.sh https://raw.githubusercontent.com/shin902/claude-marketplace/refs/heads/main/git-commit/scripts/commit-and-summarize.sh
```
これらを実行してください。