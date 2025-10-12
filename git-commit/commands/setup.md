---
description: フックに必要なシェルコマンドをセットアップします
allowed-tools: Bash(curl:+), Bash(mkdir:*), Bash(chmod:*)
---
```zsh
mkdir -p ~/.claude/scripts
curl -L -o ~/.claude/scripts/commit-and-summarize.sh https://raw.githubusercontent.com/shin902/shi-marketplace/refs/heads/main/git-commit/scripts/commit-and-summarize.sh
chmod +x ~/.claude/scripts/commit-and-summarize.sh
```

- mkdirコマンドで対象のスクリプトの保存ディレクトリを作成します
- curlコマンドで https://raw.githubusercontent.com/shin902/shi-marketplace/refs/heads/main/git-commit/scripts/commit-and-summarize.sh をダウンロードし ~/.claude/scripts/commit-and-summarize.sh に作成します
- chmodコマンドでスクリプトファイルに実行権限を付与します

これらを実行してください。