---
marp: true
theme: default
paginate: true
---

<style>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;700&display=swap');

:root {
  --color-background: #ffffff;
  --color-foreground: #1f2937;
  --color-heading: #1e40af;
  --color-accent: #3b82f6;
  --color-border: #d1d5db;
  --font-default: 'Noto Sans JP', 'Hiragino Kaku Gothic ProN', 'Meiryo', sans-serif;
}

section {
  background-color: var(--color-background);
  color: var(--color-foreground);
  font-family: var(--font-default);
  font-weight: 400;
  box-sizing: border-box;
  border-top: 8px solid var(--color-heading);
  position: relative;
  line-height: 1.7;
  font-size: 22px;
  padding: 56px;
}

h1, h2, h3, h4, h5, h6 {
  font-weight: 700;
  color: var(--color-heading);
  margin: 0;
  padding: 0;
}

h1 {
  font-size: 54px;
  line-height: 1.3;
  text-align: left;
  font-weight: 700;
  letter-spacing: -0.02em;
}

h2 {
  position: absolute;
  top: 40px;
  left: 56px;
  right: 56px;
  font-size: 38px;
  padding-top: 0;
  padding-bottom: 16px;
  border-bottom: 3px solid var(--color-accent);
}

h2 + * {
  margin-top: 112px;
}

h3 {
  color: var(--color-accent);
  font-size: 26px;
  margin-top: 32px;
  margin-bottom: 12px;
  font-weight: 600;
}

ul, ol {
  padding-left: 32px;
}

li {
  margin-bottom: 10px;
  line-height: 1.7;
}

footer {
  font-size: 16px;
  color: #6b7280;
  position: absolute;
  left: 56px;
  right: 56px;
  bottom: 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

footer::before {
  content: '';
  flex: 1;
  height: 2px;
  background-color: var(--color-border);
  margin-right: 20px;
}

section.lead {
  border-top: 8px solid var(--color-heading);
  display: flex;
  flex-direction: column;
  justify-content: center;
  background: linear-gradient(135deg, #ffffff 0%, #f3f4f6 100%);
}

section.lead footer {
  display: none;
}

section.lead h1 {
  margin-bottom: 32px;
  color: var(--color-heading);
}

section.lead p {
  font-size: 24px;
  color: var(--color-foreground);
  font-weight: 500;
}

table {
  border-collapse: collapse;
  width: 100%;
  margin: 20px 0;
  font-size: 18px;
}

th, td {
  border: 1px solid var(--color-border);
  padding: 12px;
  text-align: left;
}

th {
  background-color: var(--color-heading);
  color: #ffffff;
  font-weight: 700;
}

tr:nth-child(even) {
  background-color: #f9fafb;
}

strong {
  color: var(--color-heading);
  font-weight: 700;
}

code {
  background-color: #f3f4f6;
  color: var(--color-heading);
  padding: 2px 6px;
  border-radius: 3px;
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 0.9em;
}
</style>

<!-- _class: lead -->

# プレゼンテーション

ビジネスライク

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
