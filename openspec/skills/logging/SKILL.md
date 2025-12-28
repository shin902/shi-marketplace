---
name: logging
description: デバッグしやすいログの実装ガイド
---

# ロギングガイド

## コード例
```typescript
function processData(input) {
  logger.info('processData started', { input });

  try {
    const result = await fetchFromDB(id);
    logger.info('DB fetch succeeded', { id, result });

    const processed = transform(result);
    logger.info('processData completed', { processed });
    return processed;

  } catch (error) {
    logger.error('processData failed', { input, error });
    throw error;
  }
}
```

## 目的

「どこまで成功したか」を特定できるログにする。
