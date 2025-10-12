---
description: フックに必要なシェルコマンドをセットアップします
allowed-tools: Bash(curl:+), Bash(mkdir:*)
---
```zsh
mkdir -p ~/.claude/scripts
git archive --remote=https://github.com/shin902/shi-marketplace.git HEAD:path git-commit/scripts/commit-and-summarize.sh | tar -x -C ~/.claude/scripts/
```
これらを実行してください。