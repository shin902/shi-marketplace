---
name: security-audit
description: OSS Claude Codeアプリケーションの包括的セキュリティ監査。深刻な脆弱性、トークン露呈、権限昇格、バックドアの可能性を系統的に調査する
allowed-tools: Read, Bash, Bash(grep:*), Bash(glob:*), web_search, web_fetch, Bash(npm audit:*)
argument-hint: プラグインやMCPサーバーの名前
---

これは社外のエンジニアが作ったOSSアプリケーションです。深刻な脆弱性、特にトークンの露呈や権限周りで攻撃される可能性やバックドアが仕込まれている可能性はないかをセキュリティエンジニアとして隅から隅まで調べてください。また、CVEの情報を逐次確認してください。

特に以下の脆弱性をチェック：
- SQLインジェクション対策
- XSS脆弱性
- 認証・認可の実装
- 機密情報のハードコード
- 入力値の検証

発見した問題については、CVSSスコアと修正方法を提示してください。

ultrathink