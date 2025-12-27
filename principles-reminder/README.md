# Principles Reminder Plugin

AIの安全な運用を促進するための「AI運用5原則」をリマインドするプラグインです。

## 機能

- **原則の表示**: Claude Codeのセッション開始時およびタスク完了時に、「AI運用5原則」を表示します。
- **意識付け**: AIが適切な権限範囲で動作しているか、ユーザーとAI双方に確認を促します。

## インストール

```bash
/plugin install principles-reminder@Marketplace-of-shi
```

## AI運用5原則

このプラグインが表示する原則は、AIの暴走を防ぎ、安全かつ責任ある利用を目的としています。

## 仕組み

`hooks/hooks.json` で `Start` および `Stop` イベントをフックし、シェルスクリプトを通じて原則テキストを出力します。
