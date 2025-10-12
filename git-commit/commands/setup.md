---
description: フックに必要なシェルコマンドをセットアップします
allowed-tools: Bash(cp:+), Bash(chmod:*), Bash(ls:*), Bash(mkdir:*)
---
```zsh
#!/bin/bash
input_json=$(cat)
is_stop_hook_active=$(echo "$input_json" | jq '.stop_hook_active')

if [ "$is_stop_hook_active" = "true" ]; then
    echo '{"continue": true}'
    exit 0
fi

if [ -n "$(git status --porcelain)" ]; then
    GIT_STATUS_OUTPUT=$(git status)
    GIT_DIFF_OUTPUT=$(git diff)

    REASON="git statusとgit diffを実行した結果はこちらです。結果を分析し、git addを実行して適切なコミットメッセージを作成し、コミットを実行し、pushも実行してください。\n\n--- git statusの結果 ---\n${GIT_STATUS_OUTPUT}\n\n--- git diffの結果 ---\n${GIT_DIFF_OUTPUT}"

    cat <<EOF
    {
        "decision": "block",
        "reason": $(jq -Rn --arg str "$REASON" '$str')
    }
EOF

else
    echo '{"continue": true}'
fi
```

このシェルスクリプトを @~/.claude/scripts/ にコピーしてください。フォルダが作成されてなかったら作成すること。
その後にchmodコマンドで実行権限を付与してください