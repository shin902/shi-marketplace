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

# ── 最新レビューを取得 ─────────────────────────────────────────────────────────

REVIEWS_JSON="$(gh api "repos/${REPO}/pulls/${PR_NUMBER}/reviews" 2>&1)"

LATEST_REVIEW="$(
  echo "$REVIEWS_JSON" \
  | jq 'sort_by(.submitted_at) | last'
)"

if [[ -z "$LATEST_REVIEW" || "$LATEST_REVIEW" == "null" ]]; then
  echo "レビューが見つかりませんでした。" >&2
  exit 1
fi

REVIEW_ID="$(echo "$LATEST_REVIEW"   | jq -r '.id')"
REVIEW_URL="$(echo "$LATEST_REVIEW"  | jq -r '.html_url')"
AUTHOR="$(echo "$LATEST_REVIEW"      | jq -r '.user.login')"
STATE="$(echo "$LATEST_REVIEW"       | jq -r '.state')"
SUBMITTED="$(echo "$LATEST_REVIEW"   | jq -r '.submitted_at')"
BODY="$(echo "$LATEST_REVIEW"        | jq -r '.body // ""')"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 最新レビュー"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  投稿者    : %s\n"   "$AUTHOR"
printf "  ステータス: %s\n"   "$STATE"
printf "  日時      : %s\n"   "$SUBMITTED"
printf "  URL       : %s\n"   "$REVIEW_URL"

if [[ -n "$BODY" ]]; then
  echo ""
  echo "  ── 概要 ──────────────────────────────────────────────────────────"
  echo "$BODY" | sed 's/^/  /'
fi

# ── その review に紐づくインラインコメントを取得 ─────────────────────────────

ALL_COMMENTS_JSON="$(gh api "repos/${REPO}/pulls/${PR_NUMBER}/comments" 2>&1)"

INLINE_COMMENTS="$(
  echo "$ALL_COMMENTS_JSON" \
  | jq --argjson rid "$REVIEW_ID" \
    '[.[] | select(.pull_request_review_id == $rid)]'
)"

COMMENT_COUNT="$(echo "$INLINE_COMMENTS" | jq 'length')"

if [[ "$COMMENT_COUNT" -eq 0 ]]; then
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
