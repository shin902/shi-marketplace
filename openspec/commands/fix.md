---
allowed-tools: Task, Bash, Read, Write, Edit, Grep, Glob
description: バグ修正を行うコマンド。過去の類似バグを参照し、修正後にドキュメント化する
---

# /fix コマンド

バグ修正専用のコマンドです。過去の類似バグを探索し、修正後に記録を残します。

## 引数
$ARGUMENTS - 修正したいバグの内容

## ディレクトリ構成
```
openspec/
  └── bugs/
      └── fixed/      # 修正済みバグのドキュメント
          ├── 2025-01-01-user-auth-fix.md
          └── 2025-01-05-database-timeout.md
```

## 実行フロー

### 1. Gitブランチの作成

バグ修正用のブランチを作成してください：

```bash
# 現在のブランチを確認
git branch --show-current

# バグの内容から適切なブランチ名を生成（例: fix/user-auth-error）
# 英語のケバブケース（小文字とハイフン）で命名
new_branch="fix/[バグ内容から生成した名前]"

# ブランチを作成してチェックアウト
git checkout -b "$new_branch"

echo "ブランチ $new_branch を作成しました"
```

### 2. 過去の類似バグを探索（Exploreサブエージェント）

Exploreサブエージェントを起動して、過去のバグ修正例を探索してください：

```
Use the Explore subagent to search for similar bug fixes in the documentation.

Search target: openspec/bugs/fixed/

The Explore subagent should:
1. List all files in openspec/bugs/fixed/ directory
2. Check filenames for relevance to: $ARGUMENTS
3. Read all potentially relevant documents
4. Summarize similar bug fixes found
5. Return findings including:
   - Whether similar bugs exist (既知 or 新規)
   - Summary of similar fixes (if any)
   - Relevant patterns or solutions
```

### 3. 判断と計画立案

Exploreサブエージェントの結果を受け取り、判断してください：

#### 【既知の問題の場合】

過去に類似のバグ修正例がある場合：

- ユーザーに「類似のバグが見つかりました」と報告
- 参考にする過去の修正例を提示
- その内容を参考に、次の「実装フェーズ」へ進む

#### 【新規の問題の場合】

過去に類似例がない場合：

1. **コードを探索（Exploreサブエージェント）**
   ```
   Use the Explore subagent to investigate the codebase related to: $ARGUMENTS
   
   The Explore subagent should:
   1. Identify files likely related to this bug
   2. Read relevant source code
   3. Analyze the current implementation
   4. Find potential root causes
   ```

2. **修正計画を立案（Planサブエージェント）**
   ```
   Use the Plan subagent to create a fix plan based on the code investigation.
   
   The Plan subagent should:
   1. Analyze the root cause
   2. Propose a fix approach
   3. List files to modify
   4. Identify potential side effects
   5. Suggest test cases
   ```

3. 計画をユーザーに提示し、確認を得る
4. 次の「実装フェーズ」へ進む

### 4. 実装フェーズ

バグを修正してください：

1. **コードの修正**
   - 計画に基づいてコードを修正
   - 必要に応じてファイルを編集

2. **テストの実行**
   ```bash
   # package.jsonからテストコマンドを確認
   cat package.json | grep -A 5 "scripts"
   
   # テストを実行（例）
   npm test
   # または
   npm run test:unit
   
   # リンティング（存在する場合）
   npm run lint
   # または
   npm run typecheck
   ```

3. **テスト結果の確認**
   - すべてのテストが成功することを確認
   - 失敗した場合は修正を繰り返す（最大3回まで自動修正を試みる）

### 5. バグ修正ドキュメントの作成

修正が完了したら、`openspec/bugs/fixed/`にドキュメントを作成してください：

```bash
# ファイル名の生成（例: 2025-01-10-user-auth-error.md）
today=$(date +%Y-%m-%d)
filename="openspec/bugs/fixed/${today}-[バグ名].md"

# ドキュメントを作成
```

**ドキュメントのテンプレート:**
```markdown
# [バグ名]

作成日: YYYY-MM-DD
修正者: [名前 or 自動]
ブランチ: fix/[ブランチ名]

## バグの概要
[ユーザーが報告した内容: $ARGUMENTS]

## 類似例の調査結果
- 既知/新規: [既知 or 新規]
- 参考にした過去の修正: [ファイル名 or なし]

## 根本原因
[バグの原因]

## 修正内容
[どのように修正したか]

## 変更したファイル
- file1.ts
- file2.tsx

## テスト結果
[テストの実行結果]

## 備考
[その他特記事項があれば]
```

### 6. 完了報告

ユーザーに以下の情報を報告してください：

```
バグ修正完了:
- ブランチ: fix/[ブランチ名]
- 修正内容: [簡潔な説明]
- テスト結果: [成功/失敗の詳細]
- ドキュメント: openspec/bugs/fixed/[ファイル名]
- 変更ファイル: [リスト]

次のステップ:
- git add . でステージング
- git commit でコミット
- PRを作成して main にマージ
```
