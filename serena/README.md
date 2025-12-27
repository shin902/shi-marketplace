# Serena Plugin

Serena MCP Serverとの連携およびプロジェクト開始時のアクティベーションを支援するプラグインです。

## 機能

- **Serena MCP Server**: Claude CodeにSerena MCPサーバー機能を提供します。
- **プロジェクトアクティベーション**: セッション開始時（`Start`）に、プロジェクトのアクティベート（初期化や環境確認など）を促すフックが動作します。

## インストール

```bash
/plugin install serena@Marketplace-of-shi
```

## 構成

- `.mcp.json`: MCPサーバーの設定
- `hooks/hooks.json`: 開始時のフック定義
