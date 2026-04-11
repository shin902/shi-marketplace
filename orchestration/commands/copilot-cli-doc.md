# GitHub Copilot CLI 活用スキル

GitHub Copilot CLI (`copilot`) を使って、コーディングタスクを効率的に自動化する。

## 基本方針

1. **`-p` モード多用** — インタラクティブ UI を使わず、スクリプトとして実行して出力を受け取る
2. **1リクエストで多くをこなす** — 関連タスクを1プロンプトにまとめ、モデル呼び出しを最小化する
3. **サブタスクは直列チェーン** — 依存関係のあるステップは前のステップ出力を次の入力にして直列でつなぐ

---

## 起動フラグ早見表

### `-p` モード（プログラマティック実行）

```bash
copilot -p "プロンプト"           # 実行して終了
copilot -p "..." -s              # -s: 統計なしでレスポンスのみ出力（スクリプト向け）
copilot -p "..." --autopilot     # 自律継続モード（完了まで自動ループ）
copilot -p "..." --output-format json  # JSONL 形式で出力
```

### モデル指定

```bash
copilot --model gpt-5.3-codex -p "..."
# または環境変数で
COPILOT_MODEL=gpt-5.3-codex copilot -p "..."
```

### リーズニングエフォート指定

```bash
copilot --model gpt-5.3-codex --effort high -p "..."
copilot --model gpt-5.3-codex --reasoning-effort xhigh -p "..."
# 選択肢: low | medium | high | xhigh
```

> `xhigh` は `--effort` フラグでは指定できない場合がある（CLIバージョン依存）。
> その場合は `~/.copilot/config.json` の `effortLevel` を `"xhigh"` に設定しておく。

### 権限設定（書き込み・ビルド・テスト許可）

```bash
# ファイル書き込みを許可
copilot --allow-tool='write' -p "..."

# npm スクリプトをすべて許可
copilot --allow-tool='shell(npm run:*)' -p "..."

# git コマンドをすべて許可（push は除く）
copilot --allow-tool='shell(git:*)' --deny-tool='shell(git push)' -p "..."

# 書き込み + npm scripts + git（push除く）を一括許可
copilot \
  --allow-tool='write' \
  --allow-tool='shell(npm run:*)' \
  --allow-tool='shell(git:*)' \
  --deny-tool='shell(git push)' \
  -p "..."

# 全ツール許可（YOLO モード、信頼できる環境のみ）
copilot --yolo -p "..."
# または
COPILOT_ALLOW_ALL=true copilot -p "..."
```

---

## 推奨起動テンプレート

ほとんどのコーディングタスクに使う標準テンプレート：

```bash
copilot \
  --model gpt-5.3-codex \
  --effort high \
  --allow-tool='write' \
  --allow-tool='shell(npm run:*)' \
  --allow-tool='shell(git:*)' \
  --deny-tool='shell(git push)' \
  --autopilot \
  -s \
  -p "YOUR_PROMPT"
```

---

## 1リクエストで多くをこなすプロンプト設計

### 基本原則

- **関連する読み込み・調査・実装・テストを1プロンプトに統合する**
- ステップの順序を明示し、各ステップの完了条件を書く
- 「まず X を確認し、次に Y を実装し、最後に Z でテストせよ」という形式

### 例：機能追加 + テスト + コミットを1リクエストで

```bash
copilot \
  --model gpt-5.3-codex \
  --effort high \
  --allow-tool='write' \
  --allow-tool='shell(npm run:*)' \
  --allow-tool='shell(git:*)' \
  --deny-tool='shell(git push)' \
  --autopilot \
  -s \
  -p "
以下を順番に実行せよ。各ステップを完了してから次に進むこと。

1. src/auth/ 以下を読み込んで現在の認証フローを把握する
2. src/auth/service.ts にリフレッシュトークン機能を追加する
   - refreshToken(token: string): Promise<AuthResult> メソッドを追加
   - 既存の login() と同じエラーハンドリングパターンに従う
3. src/auth/service.test.ts にテストを追加する（既存テストパターンに合わせる）
4. npm run test -- --testPathPattern=auth を実行してテストが通ることを確認する
5. npm run build を実行してコンパイルエラーがないことを確認する
6. git add src/auth/ && git commit -m 'feat: add refresh token support'

全ステップ完了後に結果サマリーを出力せよ。
"
```

### 例：リファクタリング + lint fix + テスト

```bash
copilot \
  --model gpt-5.3-codex \
  --effort high \
  --allow-tool='write' \
  --allow-tool='shell(npm run:*)' \
  --autopilot \
  -s \
  -p "
src/utils/ 以下のファイルを対象に以下を実行せよ:

1. glob で全 .ts ファイルを列挙し、各ファイルを読み込む
2. any 型を適切な型に置き換える（型が不明な場合は unknown を使う）
3. npm run lint:fix を実行する
4. npm run test を実行してテストが壊れていないことを確認する
5. 変更したファイルの一覧と変更内容のサマリーを出力する

テストが失敗した場合は修正してから次のステップに進むこと。
"
```

---

## サブエージェント直列チェーンパターン

### パターン1：Bash スクリプトで複数 `-p` 呼び出しを直列につなぐ

前のステップの出力を次の入力に渡す：

```bash
#!/bin/bash
set -e

MODEL="gpt-5.3-codex"
COMMON_FLAGS="--model $MODEL --effort high --allow-tool='write' --allow-tool='shell(npm run:*)' -s"

# Step 1: 調査
echo "=== Step 1: 調査 ==="
RESEARCH=$(copilot $COMMON_FLAGS -p "
src/ 以下のファイル構造を調査し、以下を出力せよ（JSONで）:
- メインエントリポイント
- テストファイルのパターン
- ビルドコマンド
出力はJSONのみ。説明不要。
")
echo "$RESEARCH"

# Step 2: 実装（Step 1の結果を参照）
echo "=== Step 2: 実装 ==="
copilot $COMMON_FLAGS --autopilot -p "
以下の調査結果をもとに実装せよ:
$RESEARCH

タスク: getUserById(id: string) 関数を src/users/service.ts に追加する。
- 既存のパターンに従う
- エラーハンドリングを含める
- JSDoc を追加する
"

# Step 3: テスト実行と確認
echo "=== Step 3: テスト ==="
copilot $COMMON_FLAGS -p "
npm run test -- --testPathPattern=users を実行し、
失敗があれば修正して再実行せよ。
全テスト通過後に '✅ 完了' と出力せよ。
"
```

### パターン2：ファイルを経由してコンテキストを引き継ぐ

```bash
#!/bin/bash
PLAN_FILE="/tmp/copilot-plan-$$.md"
MODEL="gpt-5.3-codex"

# Step 1: プランを作成してファイルに保存
copilot --model $MODEL --effort high -s -p "
@src/ の構造を分析し、認証システムのリファクタリング計画を
$PLAN_FILE に Markdown で書き出せ。
実装ステップを番号付きリストで列挙し、各ステップに対象ファイルを明記せよ。
" 

# Step 2: プランに従って実装
copilot \
  --model $MODEL \
  --effort high \
  --allow-tool='write' \
  --allow-tool='shell(npm run:*)' \
  --autopilot \
  -s \
  -p "
@$PLAN_FILE のプランを実行せよ。
各ステップを完了したらチェックボックスを ✅ に更新してファイルを上書き保存し、
次のステップに進むこと。
全ステップ完了後に npm run test を実行して確認せよ。
"

# クリーンアップ
rm -f "$PLAN_FILE"
```

### パターン3：`--output-format json` でパースして次のエージェントに渡す

```bash
#!/bin/bash
MODEL="gpt-5.3-codex"

# 調査結果をJSONで受け取る
ISSUES=$(copilot \
  --model $MODEL \
  --output-format json \
  -s \
  -p "
src/ 以下を分析し、TypeScript の型エラーになりそな箇所を列挙せよ。
以下のJSON配列形式のみで出力せよ（説明不要）:
[{\"file\": \"path/to/file.ts\", \"line\": 42, \"issue\": \"説明\"}]
" | tail -1 | python3 -c "import sys,json; data=json.load(sys.stdin); print(json.dumps(data.get('content', data)))" 2>/dev/null || echo "[]")

# ファイルごとに修正（直列）
echo "$ISSUES" | python3 -c "
import sys, json, subprocess, os

issues = json.load(sys.stdin)
files = list(set(i['file'] for i in issues))

for f in files:
    file_issues = [i for i in issues if i['file'] == f]
    desc = '\n'.join(f'- Line {i[\"line\"]}: {i[\"issue\"]}' for i in file_issues)
    cmd = [
        'copilot',
        '--model', os.environ.get('MODEL', 'gpt-5.3-codex'),
        '--effort', 'high',
        '--allow-tool=write',
        '-s', '-p',
        f'{f} の以下の問題を修正せよ:\n{desc}'
    ]
    subprocess.run(cmd)
    print(f'✅ {f} 修正完了')
"
```

---

## `~/.copilot/config.json` による永続設定

セッションを跨いで設定を保持したい場合は設定ファイルを使う：

```json
{
  "model": "gpt-5.3-codex",
  "effortLevel": "high",
  "trusted_folders": ["/path/to/your/projects"]
}
```

`xhigh` を使いたい場合（CLIフラグで対応していないバージョン向け）：

```json
{
  "model": "gpt-5.3-codex",
  "effortLevel": "xhigh"
}
```

設定ファイルの場所：`~/.copilot/config.json`

---

## リポジトリ別のコマンド定義（`.github/copilot-instructions.md`）

プロジェクトのビルド・テストコマンドをあらかじめ定義しておくと、エージェントが正確なコマンドを使える：

```markdown
## Build & Test Commands
- `npm run build` - TypeScript をコンパイル
- `npm run test` - テスト実行（vitest）
- `npm run lint:fix` - ESLint 自動修正
- `npm run typecheck` - 型チェックのみ

## Workflow
- コードを変更したら必ず `npm run lint:fix && npm run typecheck && npm run test` を実行せよ
- コミット前にビルドが通ることを確認せよ
```

---

## トラブルシューティング

### `-p` モードで権限ダイアログが止まる

`-p` モードでは対話的な権限ダイアログに答えられない。`--allow-tool` で事前に許可するか `--yolo` を使う。

### `--effort xhigh` が効かない

CLIバージョンによっては `--effort` フラグが `xhigh` をサポートしていない。`~/.copilot/config.json` の `effortLevel` で設定する。

### 長いタスクが途中で止まる

`--autopilot` フラグを付けると、タスクが完了するまでエージェントが自律的に継続する。
`--max-autopilot-continues=N` で最大継続回数を指定できる。

### 出力をパイプしたい

```bash
# レスポンスのみ（統計なし）
copilot -s -p "..." | jq .

# JSONLで詳細出力
copilot --output-format json -p "..." | grep '"type":"assistant"'
```
