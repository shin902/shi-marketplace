---
name: logging
description: アプリケーションログの実装ガイド。デバッグしやすいログを適切なタイミングで出力する。
---

# ロギングガイド

## ログを入れるべき場所

```typescript
function processData(input) {
  logger.info('processData started', { input });  // 関数開始
  
  try {
    const result = await fetchFromDB(id);
    logger.info('DB fetch succeeded', { id, result });  // 重要な処理の成功
    
    const processed = transform(result);
    logger.info('processData completed', { processed });  // 関数終了
    return processed;
    
  } catch (error) {
    logger.error('processData failed', { input, error });  // エラー
    throw error;
  }
}
```

### タイミング

1. **関数の開始**: 入力パラメータを記録
2. **重要な処理の後**: DB操作、API呼び出しの成功
3. **関数の終了**: 処理結果を記録
4. **エラー発生時**: エラー内容と入力を記録

## ログレベル

- **INFO**: 通常の処理フロー
- **WARN**: 異常だが処理は継続
- **ERROR**: エラー発生

## 記録すべき情報

- **成功ログ**: 入力、結果
- **エラーログ**: 入力、エラー内容

## 目的

「どこまで成功したか」を特定できるログにする。
