# Contributing to Claude Marketplace

Claude Marketplaceへようこそ！このプロジェクトはClaude Code用のプラグインやツールを管理するマーケットプレイスです。このドキュメントでは、プロジェクトへのコントリビューション方法について説明します。

## プロジェクトの概要

このリポジトリは、Claude Codeユーザーが利用できるプラグインを収集・管理するためのマーケットプレイスです。各プラグインは独立したディレクトリに配置され、Claude Codeのプラグインシステム（コマンド、エージェント、フック、MCPサーバー）と連携して動作します。

## 開発環境のセットアップ

### 前提条件
- Claude Codeがインストールされていること
- Gitが利用可能であること
- 基本的なコマンドライン操作に慣れていること

### リポジトリのクローン
```bash
git clone https://github.com/shin902/claude-marketplace.git
cd claude-marketplace
```

## 新しいプラグインの開発

### 1. プラグインの作成

新しいプラグイン用のディレクトリを作成し、Claude Codeのプラグイン構造に従ってください：

```bash
mkdir your-plugin-name
cd your-plugin-name
mkdir .claude-plugin commands agents hooks scripts
```

### 2. プラグインメタデータの作成

`.claude-plugin/plugin.json`ファイルを作成し、プラグインの基本情報を定義してください：

```json
{
  "name": "your-plugin-name",
  "description": "プラグインの詳細な説明",
  "version": "1.0.0",
  "author": {
    "name": "作成者名"
  }
}
```

### 3. コンポーネントの追加（オプション）

#### カスタムコマンドの作成
`commands/`ディレクトリにMarkdownファイルを作成：

```markdown
---
description: コマンドの説明
allowed-tools: 許可するツール（Bash(curl:+), Bash(mkdir:*), etc.）
---

# コマンドの実行内容

ここにコマンドの詳細な説明や実行内容を記述します。

```bash
# 実行するコマンド
command-to-run
```
```

#### エージェントの作成
`agents/`ディレクトリにエージェント定義ファイルを作成：

```markdown
---
description: エージェントの説明
---

エージェントの役割や動作をここに記述します。
```

#### フックの作成
`hooks/hooks.json`ファイルを作成し、イベントハンドラーを定義：

```json
{
  "description": "フックの説明",
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "実行するコマンド"
          }
        ]
      }
    ]
  }
}
```

#### MCPサーバーの統合
必要に応じて`.mcp.json`ファイルを作成して外部ツールと連携。

### 4. マーケットプレイスへの登録

ルートの`.claude-plugin/marketplace.json`を更新して新しいプラグインを登録：

```json
{
  "name": "Marketplace-of-shi",
  "owner": {
    "name": "shi."
  },
  "plugins": [
    // 既存のプラグイン...
    {
      "name": "your-plugin-name",
      "source": "./your-plugin-name",
      "description": "プラグインの説明"
    }
  ]
}
```

## ローカル開発とテスト

### 開発用マーケットプレイスのセットアップ

プラグイン開発中は、ローカルマーケットプレイスを使ってテストできます：

1. **開発構造の作成**
```bash
mkdir dev-marketplace
cd dev-marketplace
mkdir your-plugin
```

2. **マーケットプレイス設定の作成**
```bash
mkdir .claude-plugin
cat > .claude-plugin/marketplace.json << 'EOF'
{
  "name": "dev-marketplace",
  "owner": {
    "name": "Developer"
  },
  "plugins": [
    {
      "name": "your-plugin",
      "source": "./your-plugin",
      "description": "開発中のプラグイン"
    }
  ]
}
EOF
```

3. **Claude Codeでのテスト**
```bash
cd ..
claude
/plugin marketplace add ./dev-marketplace
/plugin install your-plugin@dev-marketplace
```

4. **変更時の再テスト**
```bash
/plugin uninstall your-plugin@dev-marketplace
/plugin install your-plugin@dev-marketplace
```

### テストのポイント
- コマンドが正しく実行されるか確認（`/help`で表示されるか）
- エージェントが利用可能か確認（`/agents`で表示されるか）
- フックが期待通りに動作するか確認
- エラーハンドリングが適切か確認

## 既存プラグインの修正

既存のプラグインを修正する場合は：

1. **該当プラグインのディレクトリに移動**
```bash
cd git-commit  # または notification, serena
```

2. **変更を加える**
   - `.claude-plugin/plugin.json`のメタデータを更新
   - `commands/`のコマンドを修正
   - `hooks/hooks.json`のフックを更新
   - `scripts/`のスクリプトを修正

3. **変更をテスト**
   - ローカルマーケットプレイスでテスト
   - 既存の機能を破壊していないか確認

## プルリクエストのガイドライン

プルリクエストを作成する際は、以下の点にご注意ください：

### 必須事項
- **明確なタイトル**: 何をする変更なのかがわかるタイトル
- **詳細な説明**: 変更内容、理由、影響を説明
- **テスト済み**: 変更が正しく動作することを確認

### 推奨事項
- **小分けのコミット**: 論理的に分割されたコミット
- **ドキュメント更新**: README.mdやこのCONTRIBUTING.mdの更新
- **バージョン管理**: プラグインのversionフィールドを適切に更新

### レビューポイント
- プラグイン構造が公式ドキュメント準拠か
- JSONファイルの構文が正しいか
- セキュリティ上の懸念はないか
- パフォーマンスに悪影響がないか

## コーディング標準

### JSONファイル
- 正しいJSON形式を使用
- 適切なインデント（2スペース）
- コメントは使用せず、自己説明的なキー名を使用

### Markdownファイル
- 日本語で記述
- 読みやすいフォーマット
- コードブロックは適切な言語指定

### シェルスクリプト
- 実行権限を適切に設定（`chmod +x`）
- エラーハンドリングを考慮
- ポータブルな書き方（bash, zsh両対応）

### 命名規則
- プラグイン名: ケバブケース（`your-plugin-name`）
- ファイル名: スネークケースまたはケバブケース
- 変数名: スネークケース

## デバッグとトラブルシューティング

### プラグインが動作しない場合
1. **構造の確認**: `.claude-plugin/`ディレクトリがプラグインルートにあるか
2. **JSON構文チェック**: `plugin.json`と`hooks.json`の構文エラー
3. **コマンドテスト**: 各コンポーネントを個別にテスト
4. **ログ確認**: Claude Codeのログでエラーメッセージを確認

### 一般的な問題
- ファイルパスの間違い
- 権限の問題（スクリプトの実行権限）
- ツールの許可設定（allowed-tools）
- 依存関係の問題

## プラグインの共有

完成したプラグインを共有する場合は：

1. **ドキュメントの作成**: README.mdで使用方法を説明
2. **バージョン管理**: セマンティックバージョニングを使用
3. **マーケットプレイス**: 公式マーケットプレイスでの公開を検討
4. **コミュニティ**: 他の開発者との共有

## 参考資料

- [Claude Code Plugins Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin Marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)
- [Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [Hooks](https://docs.claude.com/en/docs/claude-code/hooks)

## 連絡先

質問や提案がある場合は、[Issues](https://github.com/shin902/claude-marketplace/issues)で報告してください。コントリビューターの皆様の参加をお待ちしています！