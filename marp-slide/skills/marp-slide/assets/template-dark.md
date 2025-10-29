---
marp: true
theme: default
paginate: true
---

<style>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;700&display=swap');

:root {
  --color-background: #1a1a1a;
  --color-foreground: #e0e0e0;
  --color-heading: #61dafb;
  --color-accent: #bb86fc;
  --color-hr: #61dafb;
  --font-default: 'Noto Sans JP', 'Hiragino Kaku Gothic ProN', 'Meiryo', sans-serif;
}

section {
  background-color: var(--color-background);
  color: var(--color-foreground);
  font-family: var(--font-default);
  font-weight: 400;
  box-sizing: border-box;
  border-bottom: 8px solid var(--color-hr);
  position: relative;
  line-height: 1.7;
  font-size: 22px;
  padding: 56px;
}

section:last-of-type {
  border-bottom: none;
}

h1, h2, h3, h4, h5, h6 {
  font-weight: 700;
  color: var(--color-heading);
  margin: 0;
  padding: 0;
}

h1 {
  font-size: 56px;
  line-height: 1.4;
  text-align: left;
  text-shadow: 0 0 20px rgba(97, 218, 251, 0.3);
}

h2 {
  position: absolute;
  top: 40px;
  left: 56px;
  right: 56px;
  font-size: 40px;
  padding-top: 0;
  padding-bottom: 16px;
}

h2::after {
  content: '';
  position: absolute;
  left: 0;
  bottom: 8px;
  width: 60px;
  height: 2px;
  background-color: var(--color-hr);
  box-shadow: 0 0 10px rgba(97, 218, 251, 0.5);
}

h2 + * {
  margin-top: 112px;
}

h3 {
  color: var(--color-accent);
  font-size: 28px;
  margin-top: 32px;
  margin-bottom: 12px;
}

ul, ol {
  padding-left: 32px;
}

li {
  margin-bottom: 10px;
}

footer {
  font-size: 0;
  color: transparent;
  position: absolute;
  left: 56px;
  right: 56px;
  bottom: 40px;
  height: 8px;
  background: linear-gradient(90deg, var(--color-heading), var(--color-accent));
  box-shadow: 0 0 20px rgba(97, 218, 251, 0.3);
}

section.lead {
  border-bottom: 8px solid var(--color-hr);
}

section.lead footer {
  display: none;
}

section.lead h1 {
  margin-bottom: 24px;
}

section.lead p {
  font-size: 24px;
  color: var(--color-foreground);
}

code {
  background-color: #2d2d2d;
  color: #61dafb;
  padding: 2px 8px;
  border-radius: 4px;
  font-family: 'Consolas', 'Monaco', monospace;
}

strong {
  color: var(--color-accent);
  font-weight: 700;
}
</style>

<!-- _class: lead -->

# プレゼンテーション

ダークモード

---

## アジェンダ

- トピック1
- トピック2
- トピック3

---

## スライド

- ポイント1
- ポイント2
- ポイント3
