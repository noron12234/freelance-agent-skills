---
name: gen-manual-pdf
description: 產出案件「給客戶看的系統使用說明書 PDF」— Pentagram 風格、中文桌面版截圖、A4 多章節、含 FAQ。沉澱自 2026-06-08 協作徵稿平台 案。
---

# gen-manual-pdf

把任一線上 Web 系統（Vercel / 自架）做成「給客戶 PM / 編輯部小編看的操作手冊」**A4 PDF**。

## 何時觸發

用戶說：
- 「做一份系統使用說明書」
- 「給客戶看的操作手冊」
- 「寫一個 PDF 給 PM」
- 「使用說明書 PDF」

不適用：純 markdown wiki（用 Notion）、API docs（用 docs.<repo>）、給開發者看的（用 ARCHITECTURE.md）。

## 設計原則

| 原則 | 怎麼做 |
|---|---|
| **給新手看** | 第二人稱「你會看到」、不寫 API / 需求書節次 / 條文引用 |
| **按使用情境分章節** | 不是按技術 / 不是按合約 §，是按「使用者一天的工作流程」|
| **截圖必須是真實桌面版** | 用 1440×900 viewport + Retina 2x deviceScaleFactor |
| **Pentagram 等級設計** | Noto Serif TC 標題 + monospace 章節編號 + terracotta 主色 + 暖米背景 + 4 色 callout |
| **不要 emoji** | callout 標題前面可以一個 emoji（💡⚠✓）、內文不要 |

## 標準章節結構（5 個 Part）

依用戶旅程：

- **PART 01 · 第一次使用** — 2 章：怎麼登入 / 怎麼設定關鍵環境（Gmail / API key）
- **PART 02 · 客戶端看到什麼** — 描述客戶端視角（即使編輯部不操作、但客服時要懂）
- **PART 03 · 你的日常** — 編輯部最常用的 4-5 章（看資料、改狀態、處理特殊情況）
- **PART 04 · 階段性任務** — 月結 / 季度 / 整體事件結束後要做的事
- **PART 05 · 進階 + FAQ** — 進階設定、客服查詢、7-10 題常見問題

## Pipeline

### Step 1 · 準備好截圖工具

複製 `capture-template.mjs`（在本 skill 目錄）到專案的 `web/` 或 `app/` 目錄、改 `BASE`、改要截的頁面清單。

關鍵設定：
```js
viewport: { width: 1440, height: 900 },
deviceScaleFactor: 2,   // Retina = PDF 印刷品質
locale: "zh-TW",
```

執行：
```bash
node capture-template.mjs
```

### Step 2 · 寫 HTML

複製 `manual-template.html` 改章節文字。CSS 不要動、字體保留（Noto Serif TC + Noto Sans TC + JetBrains Mono）。

樣式組成：
- `.cover` — 封面（terracotta band + cover-blob 漸層 + cover-promise callout）
- `.toc` — 目錄（分 5 個 part）
- `.part-divider` — 黑底分隔頁（PART 大號數字角落擺飾）
- `.chapter` — 章節（ch-tag CHAPTER 01 / h2 紅色 em 強調 / 步驟編號黑點 / callout 4 色 / 圖 + caption）
- `.qa-q .qa-a` — FAQ Q/A 樣式

### Step 3 · HTML → PDF

```bash
node print-pdf.mjs <html-path> <pdf-path>
```

Playwright headless Chromium、A4、`printBackground: true`、`preferCSSPageSize: true`。

### Step 4 · QA

```bash
pdfinfo <pdf> | grep -E "Pages|Page size"
pdftoppm -r 50 -f 1 -l 5 <pdf> /tmp/sample -png   # 抽前 5 頁看
```

檢查：
- 沒有空白頁（`.cover` `.part-divider` 不要設 height、用 min-height）
- 截圖完整不被切（fullPage 設好）
- 桌面版 layout（不要被壓成手機瘦長）

## 標準輸出

- `manual/使用說明書.html` — 原始檔
- `manual/協作徵稿平台_使用說明書.pdf` — 成品（檔名換成案件名）
- 副本放 `<case_dir>/00_客戶端/使用說明書/<案件>_使用說明書.pdf`
- `manual/` 資料夾放 `_製作端_*` 內、或拉到 `~/.claude/skills/gen-manual-pdf/_workspaces/<案件>/`

## 黃金 reference

協作徵稿平台 案 2026-06-08：
- 43 頁 A4、Pentagram 風格、16 章節 + 7 題 FAQ + 5 個 Part divider
- 截圖 21 張、桌面 1440×900 Retina

## 邊界

- ❌ 不要塞 emoji 在標題以外
- ❌ 不要引用合約 §X 條文（這是給新手、不是給工程師）
- ❌ 不要章節用「需求書 §15.3」這種開發語
- ❌ 不要在 PDF 裡加 watermark / draft 字樣（這是正式交付）
- ✓ 第二人稱「你會看到」
- ✓ 步驟編號用黑色圓點 + monospace 編號
- ✓ callout 4 色：一般（米底）/ 警告（紅）/ OK（綠）/ tip（金）
