# Claude Marketplace

Claude Code用のプラグインやツールを管理するマーケットプレイスです。このマーケットプレイスでは、開発者コミュニティが作成した便利なプラグインを共有・管理することができます。

## 利用可能なプラグイン

### git-commit-plugin
Claude Codeが停止したとき（タスクが完了したとき）に、Gitコミットを自動化するためのフックを提供します。未コミットの変更を検出し、適切な粒度でコミットメッセージを生成して自動的にコミット・プッシュを実行します。

**重要**: このプラグインを使用するには、初回に `/git-commit-plugin:setup` コマンドを実行して必要なシェルスクリプトをインストールしてください。このセットアップを行わないと、フック機能が正しく動作しません。

### notification-plugin
Claude Codeが停止したとき（タスクが完了したとき）・ツールの実行確認が必要になったときに、通知音を鳴らすためのフックを提供します。

### serena-plugin
serena MCP Server, 開始時にプロジェクトのアクティベートを促すHooksを提供します。

## インストール方法

### 前提条件
- Claude Codeがインストールされていること
- 基本的なコマンドライン操作に慣れていること

### マーケットプレイスの追加
```bash
/plugin marketplace add https://github.com/shin902/claude-marketplace
```

### プラグインのインストール
```bash
/plugin install [plugin-name]@Marketplace-of-shi
```

例:
```bash
/plugin install git-commit-plugin@Marketplace-of-shi
/plugin install notification-plugin@Marketplace-of-shi
/plugin install serena-plugin@Marketplace-of-shi
```

### インストールの確認
インストール後、以下の方法で確認できます：

1. **プラグイン管理インターフェースの確認**:
```bash
/plugin  # インストール済みプラグインの管理メニューを表示
```

2. **プラグイン固有のコマンド実行**:
各プラグインの機能を直接テストしてください。例えば：
```bash
# git-commit-pluginの場合: 実際にタスク完了時に自動コミットされることを確認
# notification-pluginの場合: 通知音が鳴ることを確認
# serena-pluginの場合: プロジェクト開始時のアクティベート確認
```

3. **プラグイン詳細の確認**:
`/plugin` コマンドから "Manage Plugins" を選択して、各プラグインの詳細と提供機能を確認してください。

## プロジェクト構造

このプロジェクトはClaude Codeのプラグインシステムに基づいて構築されています。各プラグインは以下の構造に従っています：

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # プラグインメタデータ
├── commands/                 # カスタムスラッシュコマンド（オプション）
├── agents/                   # カスタムエージェント（オプション）
├── hooks/                    # イベントハンドラー（オプション）
│   └── hooks.json
└── scripts/                  # 補助スクリプト（オプション）
```

### マーケットプレイス全体の構造
```
claude-marketplace/
├── .claude-plugin/
│   └── marketplace.json      # マーケットプレイス設定
├── git-commit/               # git-commitプラグイン
├── notification/             # notificationプラグイン
├── serena/                   # serenaプラグイン
├── CONTRIBUTING.md           # コントリビューションガイド
├── README.md                 # このファイル
└── LICENSE                   # ライセンス
```

## 新しいプラグインの開発

新しいプラグインの開発方法については、[CONTRIBUTING.md](CONTRIBUTING.md)を参照してください。プラグインの作成手順からテスト方法まで、詳細なガイドを記載しています。

## ローカル開発とテスト

プラグインの開発中は、ローカルマーケットプレイスを使ってテストできます：

1. 開発用のマーケットプレイスを作成
2. プラグインをローカルでインストール・テスト
3. 変更を加えたら再インストールしてテスト

詳細は[CONTRIBUTING.md](CONTRIBUTING.md)を参照してください。

## チームでの利用

リポジトリレベルでプラグインを設定することで、チーム全体で一貫したツール環境を確保できます。`.claude/settings.json`にマーケットプレイスとプラグインの設定を追加してください。

## 参考資料

このプロジェクトは以下の公式ドキュメントに基づいて作成されています：
- [Claude Code Plugins Documentation](https://docs.claude.com/en/docs/claude-code/plugins#organize-complex-plugins)
- [Plugin Marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)

## コントリビューション

プルリクエストは歓迎します。詳細は[CONTRIBUTING.md](CONTRIBUTING.md)を参照してください。

## ライセンス

このプロジェクトのライセンスについては[LICENSE](LICENSE)ファイルを参照してください。

## 連絡先

問題や質問がある場合は、[Issues](https://github.com/shin902/claude-marketplace/issues)で報告してください。