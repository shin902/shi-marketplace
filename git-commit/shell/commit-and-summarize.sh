#!/bin/bash

# 概要:
# Gitリポジトリに変更が残っている場合、Claudeにコミット作業を指示して停止をブロックする。
# 無限ループを防ぐため、フックが既に一度実行された後（stop_hook_active: true）は
# チェックせずに処理を継続させる。

# --- 1. 無限ループ防止チェック ---
# 標準入力からJSONを受け取り、stop_hook_activeフラグを確認する
input_json=$(cat)
is_stop_hook_active=$(echo "$input_json" | jq '.stop_hook_active')

# フラグがtrueなら、フックが既に仕事をした後なので、無条件で処理を継続させる
if [ "$is_stop_hook_active" = "true" ]; then
    echo '{"continue": true}'
    exit 0
fi

# --- 2. 変更差分の有無をチェック ---
# Gitリポジトリに変更があるかチェック
if [ -n "$(git status --porcelain)" ]; then
    # --- 変更がある場合の処理 ---

    # AIに渡したいコマンドを実行し、結果を変数に格納
    GIT_STATUS_OUTPUT=$(git status)
    GIT_DIFF_OUTPUT=$(git diff)

    # reasonに含める指示を作成
    REASON="git statusとgit diffを実行した結果はこちらです。結果を分析し、git addを実行して適切なコミットメッセージを作成し、コミットを実行し、pushも実行してください。\n\n--- git statusの結果 ---\n${GIT_STATUS_OUTPUT}\n\n--- git diffの結果 ---\n${GIT_DIFF_OUTPUT}"

    # Claudeに作業を指示し、停止をブロックするJSONを出力
    cat <<EOF
    {
        "decision": "block",
        "reason": $(jq -Rn --arg str "$REASON" '$str')
    }
EOF

else
    # --- 変更がない場合の処理 ---
    # 処理を継続して良いことを示すJSONを出力
    echo '{"continue": true}'
fi
