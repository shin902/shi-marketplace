#!/usr/bin/env bash
# get-latest-pr-review.sh
# Usage:
#   ./scripts/get-latest-pr-review.sh <PR_URL>
#   ./scripts/get-latest-pr-review.sh <PR_NUMBER> [owner/repo]
#
# Examples:
#   ./scripts/get-latest-pr-review.sh https://github.com/shin902/nanoclaw/pull/15
#   ./scripts/get-latest-pr-review.sh 15
#   ./scripts/get-latest-pr-review.sh 15 shin902/nanoclaw

set -euo pipefail

# ── 引数パース ─────────────────────────────────────────────────────────────────

PR_ARG="${1:-}"
if [[ -z "$PR_ARG" ]]; then
  echo "Usage: $0 <PR_URL | PR_NUMBER> [owner/repo]" >&2
  exit 1
fi

# PR URL から owner/repo と番号を抽出
if [[ "$PR_ARG" =~ ^https://github\.com/([^/]+/[^/]+)/pull/([0-9]+) ]]; then
  REPO="${BASH_REMATCH[1]}"
  PR_NUMBER="${BASH_REMATCH[2]}"
else
  PR_NUMBER="$PR_ARG"
  if [[ -n "${2:-}" ]]; then
    REPO="$2"
  else
    # git remote から推測
    REMOTE_URL="$(git remote get-url origin 2>/dev/null || true)"
    if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+/[^.]+)(\.git)?$ ]]; then
      REPO="${BASH_REMATCH[1]}"
    else
      echo "Error: リポジトリを特定できませんでした。owner/repo を第2引数で指定してください。" >&2
      exit 1
    fi
  fi
fi

echo "📦 Repo   : $REPO"
echo "🔀 PR     : #$PR_NUMBER"
echo ""

# ── 両方のデータを取得 ─────────────────────────────────────────────────────────

REVIEWS_JSON="$(gh api "repos/${REPO}/pulls/${PR_NUMBER}/reviews" 2>&1)"
ISSUE_COMMENTS_JSON="$(gh api "repos/${REPO}/issues/${PR_NUMBER}/comments" 2>&1)"
REVIEW_COMMENTS_JSON="$(gh api "repos/${REPO}/pulls/${PR_NUMBER}/comments" 2>&1)"

# ── 最新の「レビュー」または「issueコメント」を見つける ─────────────────────────

# レビューは submitted_at、issueコメントは created_at を使用
LATEST_REVIEW_ITEM="$(
  echo "{\"reviews\": $REVIEWS_JSON, \"issue_comments\": $ISSUE_COMMENTS_JSON}" \
  | jq '
    (.reviews // []) as $r |
    (.issue_comments // []) as $ic |
    (
      ($r | map({type: "review", id: .id, user: .user.login, html_url: .html_url, time: .submitted_at, body: (.body // "")})) +
      ($ic | map({type: "issue_comment", id: .id, user: .user.login, html_url: .html_url, time: .created_at, body: (.body // "")}))
    ) |
    sort_by(.time) |
    last
  '
)"

if [[ -z "$LATEST_REVIEW_ITEM" || "$LATEST_REVIEW_ITEM" == "null" ]]; then
  echo "レビューが見つかりませんでした。" >&2
  exit 1
fi

ITEM_TYPE="$(echo "$LATEST_REVIEW_ITEM" | jq -r '.type')"
ITEM_ID="$(echo "$LATEST_REVIEW_ITEM"   | jq -r '.id')"
ITEM_URL="$(echo "$LATEST_REVIEW_ITEM"  | jq -r '.html_url')"
ITEM_AUTHOR="$(echo "$LATEST_REVIEW_ITEM" | jq -r '.user')"
ITEM_TIME="$(echo "$LATEST_REVIEW_ITEM"  | jq -r '.time')"
ITEM_BODY="$(echo "$LATEST_REVIEW_ITEM"  | jq -r '.body')"

if [[ "$ITEM_TYPE" == "review" ]]; then
  LABEL="📋 最新レビュー"
else
  LABEL="💬 最新コメント"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$LABEL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  投稿者    : %s\n"   "$ITEM_AUTHOR"
printf "  タイプ    : %s\n"   "$ITEM_TYPE"
printf "  日時      : %s\n"   "$ITEM_TIME"
printf "  URL       : %s\n"   "$ITEM_URL"

if [[ -n "$ITEM_BODY" && "$ITEM_BODY" != "null" ]]; then
  echo ""
  echo "  ── 概要 ──────────────────────────────────────────────────────────"
  echo "$ITEM_BODY" | sed 's/^/  /'
fi

# ── インラインコメントを取得 ───────────────────────────────────────────────────

# 最新レビューに紐づくインラインコメントを検索
INLINE_COMMENTS=""
if [[ "$ITEM_TYPE" == "review" ]]; then
  # まずはプルリク全体のコメントから検索
  INLINE_COMMENTS="$(
    echo "$REVIEW_COMMENTS_JSON" \
    | jq --argjson rid "$ITEM_ID" \
      '[.[] | select(.pull_request_review_id == $rid)]'
  )"
  
  # 見つからない場合は reviews/{id}/comments エンドポイントを試す
  COMMENT_COUNT="$(echo "$INLINE_COMMENTS" | jq 'length')"
  if [[ "$COMMENT_COUNT" -eq 0 ]]; then
    INLINE_COMMENTS="$(gh api "repos/${REPO}/pulls/${PR_NUMBER}/reviews/${ITEM_ID}/comments" 2>&1)"
  fi
fi

COMMENT_COUNT="$(echo "$INLINE_COMMENTS" | jq 'length')"

if [[ -z "$INLINE_COMMENTS" || "$INLINE_COMMENTS" == "null" || "$COMMENT_COUNT" -eq 0 ]]; then
  echo ""
  echo "  (インラインコメントなし)"
else
  echo ""
  echo "  ── インラインコメント ($COMMENT_COUNT 件) ────────────────────────────────────"

  echo "$INLINE_COMMENTS" | jq -c '.[]' | while IFS= read -r comment; do
    C_AUTHOR="$(echo "$comment" | jq -r '.user.login')"
    C_PATH="$(echo "$comment"   | jq -r '.path')"
    C_LINE="$(echo "$comment"   | jq -r '.line // .original_line // "?"')"
    C_BODY="$(echo "$comment"   | jq -r '.body')"
    C_URL="$(echo "$comment"    | jq -r '.html_url')"
    C_REPLY="$(echo "$comment"  | jq -r '.in_reply_to_id // empty')"

    echo ""
    if [[ -n "$C_REPLY" ]]; then
      printf "  [返信] %s → %s L%s\n" "$C_AUTHOR" "$C_PATH" "$C_LINE"
    else
      printf "  [コメント] %s → %s L%s\n" "$C_AUTHOR" "$C_PATH" "$C_LINE"
    fi
    printf "  %s\n" "$C_URL"
    echo "  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"
    echo "$C_BODY" | sed 's/^/  /'
  done
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
