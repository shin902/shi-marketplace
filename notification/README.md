# Notification Plugin

Claude Codeのイベントに合わせて通知音を鳴らすプラグインです。長時間のタスク実行中にバックグラウンドで作業していても、完了や確認待ちにすぐに気づくことができます。

## 機能

- **完了通知**: タスクが完了（Claude Codeが停止）したときに通知音を鳴らします。
- **確認待ち通知**: ツールの実行確認など、ユーザーの入力が必要になったときに通知音を鳴らします。

## インストール

```bash
/plugin install notification-plugin@Marketplace-of-shi
```

## 仕組み

`hooks/hooks.json` で定義されたフックを利用しています。
- `Stop`: タスク完了時
- `ToolConfirmation`: ツール実行の承認待ち時

それぞれのタイミングでシステムサウンドを再生します。

## 動作環境

- macOS (afplayコマンドを使用)
