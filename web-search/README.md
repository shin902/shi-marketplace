# Web Search Plugin

Gemini CLIを使用したウェブサーチ機能を提供するプラグインです。Claude Codeから直接、最新のウェブ情報を検索・取得することができます。

## 機能

- **Web検索**: `scripts/web-search.sh` を通じてGemini CLIを利用し、ウェブ上の情報を検索・要約して提示します。
- **高度な検索スキル**: 複雑な質問や調査タスクに対応するための `web-search` スキルを提供します。

## インストール

```bash
/plugin install web-search@Marketplace-of-shi
```

## 使い方

インストール後、Claude Codeは必要に応じて自動的にWeb検索スキルを使用します。また、明示的に指示することも可能です。

## クレジット

このプラグインは [claude-code-marketplace](https://github.com/getty104/claude-code-marketplace) の成果物をベースにしています。