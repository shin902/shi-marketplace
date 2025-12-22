---
description: PDFファイルをマークダウンファイルに変換する
allowed-tools: Read, Write
argument-hint: PDF File
---

## Instructions
- $ARGUMENTS にPDFファイル名が指定されます。
- 最初にobsidian のプロパティ形式を作成してください。
- 抽出されたコンテンツを、整えられたMarkdown形式に変換してください。
- 出力がクリーンで、Obsidianノートとして保存できるようにしてください。
- 要約ではなく、ファイル形式の変換です。元の文章を、読みやすい形でそのまま文字起こしすること

## Obsidian Property Format
```Markdown
---
title: ""
source: ""
author: ""
published: YYYY-MM-DD
created: YYYY-MM-DD
---
```

## Obsidian Property Generation Rules
- Obsidian Property Format に記載した Markdown をファイルの先頭に以下の編集を行った後、必ず挿入してください
- title には PDFのタイトルを""で囲んだ文字列として入れてください。このtitle名に拡張子 md を付与し、Clippings フォルダに配置してください。
- source には、PDFのファイル名を入れてください。
- author には、PDFの著者名（ペンネームや匿名もあります）を入れてください
- published には、PDFにある作成日を入れてください
- created には、本日のシステムdate を入れてください

## PDF page Conversion Rules
- 1ページ単位で処理を行います
- 文字サイズが最も大きい文字が見出しとして扱い、'# '（見出しと思われる文字サイズが複数ある場合には、'## 'や'### 'を使ってください）
- 文字サイズが同じと思われる部分は、改行されていても読み取った文字を継続してください
