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

例:
> Next.js 15の新機能について調べてください

## 具体的な使用例

### 例1: 技術情報の検索
Next.js 15の新機能について調べる場合：

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/web-search.sh "Next.js 15の新機能について、公式リリースノートや技術記事から最新情報を調べて、主要な新機能とその概要を教えてください"
```

### 例2: ライブラリのドキュメント検索
React QueryのuseQueryフックの使い方を調べる場合：

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/web-search.sh "React QueryのuseQueryフックの基本的な使い方を、公式ドキュメントから調べて、コード例を含めて説明してください"
```

### 例3: エラーメッセージの解決方法検索
TypeScriptのエラー対処法を調べる場合：

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/web-search.sh "TypeScriptで 'Type string is not assignable to type number' というエラーが発生する原因と、具体的な解決方法を調べてください"
```

### 例4: 最新ニュースの検索
Claude AIの最新アップデート情報を知りたい場合：

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/web-search.sh "Claude AIの2025年の最新アップデート情報を調べて、リリース日や主要な変更点をまとめてください"
```

### 例5: ベストプラクティスの検索
Reactのパフォーマンス最適化方法を調べる場合：

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/web-search.sh "Reactアプリケーションのパフォーマンスを最適化するベストプラクティスを調べて、主要なテクニックとその適用方法を説明してください"
```

### 例6: 比較情報の検索
ViteとWebpackの違いを理解したい場合：

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/web-search.sh "ViteとWebpackを比較して、主要な違い、それぞれのメリット・デメリット、使い分けの推奨を調べてください"
```

## 検索クエリのポイント

### 効果的な検索クエリの作り方

1. **明確な質問形式**
   - 「〜について教えてください」「〜を調べてください」など、明確な依頼として記述
   - 知りたい内容を具体的に指定

2. **情報源の指定**
   - 「公式ドキュメントから」「リリースノートから」など、参照してほしい情報源を明記
   - より正確な情報が必要な場合に有効

3. **回答形式の指定**
   - 「コード例を含めて」「表形式で」など、望む回答の形式を指定
   - 「主要な〜をリストアップ」など、まとめ方を指示

4. **時期や条件の指定**
   - 「2025年の」「最新の」など、情報の鮮度を指定
   - 「初心者向けに」「詳しく」など、詳細度を調整

5. **比較や分析の指示**
   - 「比較して」「違いを」など、分析の観点を明確に
   - 「メリット・デメリット」「使い分け」など、求める分析内容を指定

## クレジット

このプラグインは [claude-code-marketplace](https://github.com/getty104/claude-code-marketplace) の成果物をベースにしています。