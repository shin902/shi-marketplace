#!/usr/bin/env bash
set -euo pipefail

# agent-reach – CLI port of my-discord-agent's agent-reach tool
# Usage: agent-reach.sh <URL>
# Outputs fetched content to stdout. Pipe to file with > if needed.

VERSION="0.1.0"

# ── Helpers ──────────────────────────────────────────────────────────────────

die() { echo "error: $*" >&2; exit 1; }

# ── Cleanup ───────────────────────────────────────────────────────────────────
_cleanup_paths=()
_register_cleanup() { _cleanup_paths+=("$@"); }
_cleanup() {
  for p in "${_cleanup_paths[@]+"${_cleanup_paths[@]}"}"; do
    rm -rf "$p"
  done
}
trap _cleanup EXIT

usage() {
  cat <<EOF
agent-reach v${VERSION}

Usage: agent-reach.sh <URL>

Fetches content from the given URL and outputs to stdout.
Auto-detects service type (YouTube, GitHub, RSS, web).
EOF
}

# Check required external commands exist
check_cmd() {
  if ! command -v "$1" &>/dev/null; then
    die "'$1' is not installed"
  fi
}

# ── URL validation ───────────────────────────────────────────────────────────

validate_url() {
  local url="$1"
  # Must start with http:// or https://
  if [[ ! "$url" =~ ^https?:// ]]; then
    die "unsupported protocol (only http/https allowed): $url"
  fi
}

# ── Service detection ────────────────────────────────────────────────────────

detect_service() {
  local url="$1"
  local after_scheme="${url#*://}"
  local host="${after_scheme%%/*}"
  host="${host#www.}"

  local path=""
  if [[ "$after_scheme" == */* ]]; then
    path="/${after_scheme#*/}"
    path="${path%%\#*}"
    path="${path%%\?*}"
  fi
  path=$(printf '%s' "$path" | tr '[:upper:]' '[:lower:]')

  case "$host" in
    youtube.com|youtu.be) echo "youtube" ;;
    github.com)
      if [[ "$path" =~ ^/[^/]+/[^/?#]+/?$ ]]; then
        echo "github-repo"
      else
        echo "web"
      fi
      ;;
    x.com|www.x.com|twitter.com|www.twitter.com)
      if [[ "$path" =~ ^/[^/]+/status/[0-9]+ ]]; then
        echo "x-twitter"
      else
        echo "web"
      fi
      ;;
    *)
      if [[ "$path" == *.xml || "$path" == *.rss || "$path" == */feed* || "$path" == */rss* ]]; then
        echo "rss"
      else
        echo "web"
      fi
      ;;
  esac
}

# ── Formatters ───────────────────────────────────────────────────────────────

format_duration() {
  local secs="$1"
  local h m s
  h=$((secs / 3600))
  m=$(( (secs % 3600) / 60 ))
  s=$((secs % 60))
  if (( h > 0 )); then
    printf "%d:%02d:%02d" "$h" "$m" "$s"
  else
    printf "%d:%02d" "$m" "$s"
  fi
}

# YouTube: yt-dlp JSON → Markdown
format_youtube() {
  local meta_json="$1"
  local subs_dir="$2"

  # Extract JSON (yt-dlp may prepend WARNING lines)
  local json
  json=$(sed -n '/^{/,$ p' "$meta_json")
  if [[ -z "$json" ]]; then
    echo "(metadata read failed)"
    return
  fi

  local title channel upload_date duration views likes tags description
  title=$(echo "$json" | jq -r '.title // empty')
  channel=$(echo "$json" | jq -r '(.channel // .uploader // empty)')
  upload_date=$(echo "$json" | jq -r '.upload_date // empty')
  duration=$(echo "$json" | jq -r '.duration // empty')
  views=$(echo "$json" | jq -r '.view_count // empty')
  likes=$(echo "$json" | jq -r '.like_count // empty')
  tags=$(echo "$json" | jq -r '(.tags // []) | join(", ")')
  description=$(echo "$json" | jq -r '.description // empty')

  # Title
  echo "# ${title:-"(タイトル不明)"}"
  echo ""

  # Channel
  if [[ -n "$channel" ]]; then
    echo "**チャンネル**: ${channel}"
  fi

  # Upload date (YYYYMMDD → YYYY-MM-DD)
  if [[ ${#upload_date} -eq 8 ]]; then
    echo "**投稿日**: ${upload_date:0:4}-${upload_date:4:2}-${upload_date:6:2}"
  fi

  # Duration
  if [[ -n "$duration" && "$duration" != "null" ]]; then
    echo "**再生時間**: $(format_duration "$duration")"
  fi

  # Views
  if [[ -n "$views" && "$views" != "null" ]]; then
    printf "**視聴回数**: %'d\n" "$views"
  fi

  # Likes
  if [[ -n "$likes" && "$likes" != "null" ]]; then
    printf "**いいね**: %'d\n" "$likes"
  fi

  # Tags
  if [[ -n "$tags" ]]; then
    echo "**タグ**: ${tags}"
  fi

  # Description
  if [[ -n "$description" ]]; then
    echo ""
    echo "## 説明"
    echo ""
    echo "$description"
  fi

  # Chapters
  local chapters_count
  chapters_count=$(echo "$json" | jq '.chapters // [] | length')
  if (( chapters_count > 0 )); then
    echo ""
    echo "## チャプター"
    echo ""
    echo "$json" | jq -r '
      def fmt_dur:
        . as $s |
        ($s / 3600 | floor) as $h |
        (($s % 3600) / 60 | floor) as $m |
        ($s % 60) as $sec |
        if $h > 0 then
          "\($h):\($m | tostring | if length < 2 then "0" + . else . end):\($sec | tostring | if length < 2 then "0" + . else . end)"
        else
          "\($m):\($sec | tostring | if length < 2 then "0" + . else . end)"
        end;
      .chapters[] | "\(.start_time | floor | fmt_dur) \(.title // "")"
    '
  fi

  # Subtitles
  local sub_files
  sub_files=$(find "$subs_dir" -maxdepth 1 -name '*.vtt' 2>/dev/null || true)
  if [[ -n "$sub_files" ]]; then
    while IFS= read -r vtt_file; do
      local lang base_name
      base_name=$(basename "$vtt_file")
      lang="${base_name%.vtt}"
      lang="${lang##*.}"
      local text
      # Parse VTT: strip timestamps, cue numbers, timing tags, deduplicate.
      # Some YouTube VTT files collapse cue timings into the text line, so
      # remove cue timing ranges wherever they appear before line-oriented parsing.
      text=$(awk '
        BEGIN { seen_count = 0 }
        /^WEBVTT/ { next }
        /^Kind:/ { next }
        /^Language:/ { next }
        /^[0-9]+$/ { next }
        /<[0-9][0-9]:[0-9][0-9]:[0-9][0-9][.,][0-9][0-9][0-9]>/ { next }
        {
          # Some YouTube VTT files collapse cue timings into the text line, so
          # remove cue timing ranges wherever they appear before line-oriented parsing.
          gsub(/[0-9][0-9]:[0-9][0-9]:[0-9][0-9][.,][0-9][0-9][0-9][[:space:]]*-->[[:space:]]*[0-9][0-9]:[0-9][0-9]:[0-9][0-9][.,][0-9][0-9][0-9]([[:space:]]+(align:[[:alpha:]-]+|position:[^[:space:]%]+%?|line:[^[:space:]%]+%?|size:[^[:space:]%]+%?|vertical:[[:alpha:]-]+))*/, "")
          gsub(/[[:space:]]*-->[[:space:]]*[0-9][0-9]:[0-9][0-9]:[0-9][0-9][.,][0-9][0-9][0-9]([[:space:]]+(align:[[:alpha:]-]+|position:[^[:space:]%]+%?|line:[^[:space:]%]+%?|size:[^[:space:]%]+%?|vertical:[[:alpha:]-]+))*/, "")
          gsub(/<[^>]+>/, "")
          gsub(/^[[:space:]]+|[[:space:]]+$/, "")
          if (length($0) == 0) next
          if (!seen[$0]) {
            seen[$0] = 1
            lines[++n] = $0
          }
        }
        END {
          s = ""
          for (i = 1; i <= n; i++) {
            s = (s == "" ? "" : s " ") lines[i]
          }
          gsub(/。/, "。\n", s)
          printf "%s", s
        }
      ' "$vtt_file")
      if [[ -n "$text" ]]; then
        echo ""
        echo "## 字幕 (${lang})"
        echo ""
        echo "$text"
      fi
    done <<< "$sub_files"
  else
    echo ""
    echo "## 字幕"
    echo ""
    echo "(取得できませんでした)"
  fi
}

# ── Fetchers ─────────────────────────────────────────────────────────────────

fetch_youtube() {
  local url="$1"
  check_cmd yt-dlp

  local tmp_dir
  tmp_dir=$(mktemp -d)
  _register_cleanup "$tmp_dir"

  local base="${tmp_dir}/yt"
  local meta_out="${base}.meta.json"
  local subs_dir="${base}.subs"
  mkdir -p "$subs_dir"

  # Fetch metadata JSON
  yt-dlp --no-check-certificate --dump-json "$url" > "$meta_out" 2>&1

  # Fetch subtitles (best effort)
  yt-dlp --no-check-certificate --write-auto-subs --sub-lang ja,en --skip-download \
    -o "${subs_dir}/%(id)s" "$url" > /dev/null 2>&1 || true

  format_youtube "$meta_out" "$subs_dir"
}

fetch_github_repo() {
  local url="$1"
  check_cmd curl
  check_cmd jq

  local repo_path after_scheme path_part owner repo
  after_scheme="${url#*://}"
  path_part="${after_scheme#*/}"
  path_part="${path_part%%\#*}"
  path_part="${path_part%%\?*}"
  owner="${path_part%%/*}"
  repo="${path_part#*/}"
  repo="${repo%%/*}"
  repo_path="${owner}/${repo}"

  local api_base="https://api.github.com/repos/${repo_path}"

  local repo_json
  repo_json=$(curl -sf -H "Accept: application/vnd.github.v3+json" "${api_base}") \
    || die "GitHub API error for ${repo_path} (check if the repo is public)"

  local name description language license stars forks issues homepage is_fork created updated topics
  name=$(echo "$repo_json" | jq -r '.full_name // empty')
  description=$(echo "$repo_json" | jq -r '.description // empty')
  language=$(echo "$repo_json" | jq -r '.language // "Unknown"')
  license=$(echo "$repo_json" | jq -r '.license.name // "No License"')
  stars=$(echo "$repo_json" | jq -r '.stargazers_count')
  forks=$(echo "$repo_json" | jq -r '.forks_count')
  issues=$(echo "$repo_json" | jq -r '.open_issues_count')
  homepage=$(echo "$repo_json" | jq -r '.homepage // empty')
  is_fork=$(echo "$repo_json" | jq -r '.fork')
  created=$(echo "$repo_json" | jq -r '.created_at // empty')
  updated=$(echo "$repo_json" | jq -r '.updated_at // empty')
  topics=$(echo "$repo_json" | jq -r '(.topics // []) | join(", ")')

  echo "# ${name:-"${repo_path}"}"
  echo ""
  if [[ -n "$description" ]]; then
    echo "${description}"
    echo ""
  fi
  echo "**Language**: ${language} | **License**: ${license} | **Stars**: ${stars} | **Forks**: ${forks} | **Open Issues**: ${issues}"
  [[ -n "$topics" ]] && echo "**Topics**: ${topics}"
  [[ -n "$homepage" ]] && echo "**Homepage**: ${homepage}"
  echo "**Fork**: ${is_fork} | **Created**: ${created} | **Updated**: ${updated}"
  echo "**URL**: https://github.com/${repo_path}"
  echo ""
  echo "---"
  echo ""

  local readme
  readme=$(curl -sf -H "Accept: application/vnd.github.v3.raw" "${api_base}/readme" 2>/dev/null || true)

  if [[ -n "$readme" ]]; then
    echo "## README"
    echo ""
    echo "$readme"
  else
    echo "*(README not found)*"
  fi
}

fetch_x_twitter() {
  local url="$1"
  check_cmd curl
  check_cmd jq

  local username tweetId after_scheme path_part rest
  after_scheme="${url#*://}"
  path_part="${after_scheme#*/}"
  path_part="${path_part%%\#*}"
  path_part="${path_part%%\?*}"
  username="${path_part%%/*}"
  rest="${path_part#*/}"
  if [[ "$rest" != status/* ]]; then
    die "X/Twitter URL からツイートIDを取得できません: ${url}"
  fi
  tweetId="${rest#status/}"
  tweetId="${tweetId%%/*}"

  local json
  json=$(curl -sf "https://api.fxtwitter.com/${username}/status/${tweetId}") \
    || die "fxtwitter API error for ${url}"

  local code
  code=$(echo "$json" | jq -r '(.code // 0) | tostring')
  [[ "$code" != "200" ]] && die "fxtwitter API returned code ${code} for ${url}"

  local text screen_name author_name created_at likes retweets replies views
  text=$(echo "$json"        | jq -r '.tweet.text // ""')
  screen_name=$(echo "$json" | jq -r '.tweet.author.screen_name // ""')
  author_name=$(echo "$json" | jq -r '.tweet.author.name // ""')
  created_at=$(echo "$json"  | jq -r '.tweet.created_at // ""')
  likes=$(echo "$json"       | jq -r 'if .tweet.likes != null then (.tweet.likes|tostring) else "" end')
  retweets=$(echo "$json"    | jq -r 'if .tweet.retweets != null then (.tweet.retweets|tostring) else "" end')
  replies=$(echo "$json"     | jq -r 'if .tweet.replies != null then (.tweet.replies|tostring) else "" end')
  views=$(echo "$json"       | jq -r 'if .tweet.views != null then (.tweet.views|tostring) else "" end')

  echo "# @${screen_name} (${author_name})"
  echo ""
  echo "${text}"
  echo ""
  [[ -n "$created_at" ]] && echo "**投稿日時**: ${created_at}"
  [[ -n "$likes"      ]] && echo "**いいね**: ${likes}"
  [[ -n "$retweets"   ]] && echo "**リツイート**: ${retweets}"
  [[ -n "$replies"    ]] && echo "**返信**: ${replies}"
  [[ -n "$views"      ]] && echo "**表示回数**: ${views}"
}

fetch_rss() {
  local url="$1"
  check_cmd python3
  python3 -c "import feedparser" 2>/dev/null || die "'feedparser' Python package is not installed (pip install feedparser)"

  python3 -c "
import feedparser, json, sys
f = feedparser.parse(sys.argv[1])
entries = [{'title': e.title, 'link': e.link, 'summary': getattr(e, 'summary', '')} for e in f.entries[:20]]
print(json.dumps(entries, ensure_ascii=False, indent=2))
" "$url"
}

fetch_web() {
  local url="$1"
  check_cmd curl

  curl -sf "https://r.jina.ai/${url}"
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
  if [[ $# -lt 1 ]]; then
    usage
    exit 1
  fi

  local url="$1"

  validate_url "$url"

  local service
  service=$(detect_service "$url")

  case "$service" in
    youtube)      fetch_youtube "$url" ;;
    github-repo)  fetch_github_repo "$url" ;;
    x-twitter)    fetch_x_twitter "$url" ;;
    rss)          fetch_rss "$url" ;;
    web)          fetch_web "$url" ;;
    *)            die "unknown service: $service" ;;
  esac
}

main "$@"
