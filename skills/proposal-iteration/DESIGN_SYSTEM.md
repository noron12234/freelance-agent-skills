# 需求書/提案書 美術系統（次元創意 v1）

> 沉澱自製造業客戶 v1.4。「Pentagram / IDEO / Linear 等級、灰階也要精緻」的執行標準。

## 設計風格定位

**Editorial 雜誌排版風** — 對標：
- Pentagram studio 印刷品
- Linear changelog
- Apple 產品白皮書
- Wired magazine spreads
- IDEO case study PDFs

不是 SaaS landing page、不是 PPT、不是企劃書。**這是一份「印刷品質」的提案文件**。

## 色彩系統（7 色 palette）

```css
:root {
  --ink:       #0E1A1F;  /* 主深色 · 正文、章節 cover 背景、黑底 highlight box */
  --ink-2:     #364046;  /* 次要文字 · 正文段落（比 ink 略柔） */
  --line:      #E5E1D8;  /* 分隔線 · h-rule、表格 border */
  --cream:     #F7F4ED;  /* 米色背景 · 重要 box、推薦方案的 background */
  --paper:     #FBFAF6;  /* 主背景紙色 · 整體 body 背景 */
  --gold:      #B8956A;  /* 主金 · B 主推方案、CTA、強調、章節 label-gold */
  --gold-deep: #8B6E3A;  /* 深金 · A 方案、章節數字 label */
  --teal:      #1F4742;  /* 藍綠 · C 方案、平台級別、第三色 */
  --rust:      #A84F2C;  /* 警告紅 · 「不含」項、刪除線、警示 */
  --muted:     #6B7378;  /* 灰 · 次要資訊、註解、metadata */
}
```

### 顏色用法規則
- **每個方案一個 brand color**：A=gold-deep / B=gold / C=teal
- **B 主推用最強對比**：黑底 + gold 文字（其他方案用淺底）
- **rust 只用在「不含」「不要做」「警示」** — 不要爛用、會減弱專業感
- **muted 永遠是輔助資訊**（價值對比、metadata）— 不寫主賣點

## 字型系統（3 套字 + 4 種用法）

```css
body {
  font-family: 'Inter', 'Noto Sans TC', system-ui, sans-serif;
}

.serif {
  font-family: 'Noto Sans TC', 'Inter', serif;
  font-weight: 700;
  /* 大標、章節標、報價數字、「為什麼是這套系統」式論述 */
}

.num-display {
  font-family: 'Inter';
  font-weight: 200;       /* 極細 — 對比強烈 */
  font-feature-settings: "tnum" 1;  /* tabular numerals 對齊 */
  /* 報價數字、章節編號 01·02·03、KPI 數字 */
}

.mono {
  font-family: 'JetBrains Mono', monospace;
  font-feature-settings: "tnum" 1;
  /* UI mockup 內的 URL、後台代碼、時間戳 */
}

.label {
  font-size: 10-11px;
  letter-spacing: 0.08-0.12em;  /* 寬鬆 letter-spacing */
  text-transform: uppercase;     /* 全大寫 */
  color: var(--muted);
  /* 章節標籤、區塊小標、「PREPARED BY」「DOCUMENT VERSION」式 metadata */
}
```

### 字型用法規則
- **大標 .serif text-3xl/4xl** + 緊密 `letter-spacing:-0.01em ~ -0.02em`（注意是負值 — 顯得緻密、modern）
- **正文 14-15px** + `line-height:1.75-1.85`（呼吸感）
- **報價 num-display weight:200** — 極細搭配大字級（32-44px）製造對比張力
- **label 一律 uppercase + letter-spacing 寬** — 提供「印刷感」
- **混字技巧**：標題裡的英文/數字保持 Inter，中文用 Noto Sans TC，自動 fallback 不用手動切

## 版面系統

```css
.page {
  width: 210mm;          /* A4 */
  min-height: 297mm;     /* 100vh */
  padding: 60-80px 60-80px;
  background: var(--paper);
  page-break-after: always;
}

.grid {
  /* Tailwind 風格 12-column grid */
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 16-40px;
}
```

### 版面規則
- **A4 full-bleed**（margin 0）— 背景色到邊、設計感最強
- **12-column grid** — Tailwind grid-cols-12，內容欄分 5/7 或 4/8 製造比例
- **內容區左右 padding：60-80px**（不要 100px 以上會顯空）
- **段落 max-width：560-680px** — 中文段落控制行寬、不要拉太長
- **章節 cover 頁** = ink 深背景 + 大字 serif 標題置中或左對齊
- **內容頁** = paper 淺背景 + 12-column grid 排版
- **每頁頂部統一**：label 章節標 + h-rule 分隔線 + 主標 + 引言段

## 核心元件 vocabulary（class 命名）

```html
<!-- 章節麵包屑 + 分隔線（每頁頂部必備）-->
<div class="label">02 · Functional Spec · Part 1</div>
<div class="h-rule mt-3 mb-12"></div>

<!-- 主標 -->
<h2 class="serif text-3xl" style="letter-spacing:-0.01em;">章節主標</h2>

<!-- Hero 數字 -->
<div class="num-display" style="font-size:120px;">A</div>
<div class="num-display" style="font-size:36px;">NT$ 820,000</div>

<!-- 推薦徽章 -->
<div class="chip chip-gold">RECOMMENDED</div>

<!-- 螢光標示（A、B、C 字母）-->
<span class="marker-gold">B</span>

<!-- 重要 box（cream 底 + gold 左邊框）-->
<div class="p-5" style="background:var(--cream); border-left:3px solid var(--gold-deep);">
  <div class="label mb-2">為什麼推薦 B</div>
  <p>...</p>
</div>

<!-- 黑底 highlight box（殺手條款 / CTA / 結尾） -->
<div class="p-3" style="background:var(--ink); color:var(--cream); border-left:3px solid var(--gold);">
  <div class="label" style="color:var(--gold);">合約週期</div>
  <p>...</p>
</div>

<!-- 規格表 -->
<table class="spec">
  <thead><tr><th>欄位</th><th>邏輯</th></tr></thead>
  <tbody><tr><td>...</td><td>...</td></tr></tbody>
</table>

<!-- 功能列 -->
<div class="feature-row"><strong>Email + LINE 通知</strong>（催繳 / 提醒 / 月報自動寄送）</div>

<!-- 金色分隔線（章節結尾或 CTA 前）-->
<div class="h-rule-gold"></div>
```

## UI Mockup 樣式（Visual Part 用）

需求書 Part 2 視覺章節要有實際 UI 截圖風格的 mockup：

```html
<!-- 瀏覽器框架 + URL bar -->
<div class="browser-frame">
  <div class="browser-tabs">
    <span class="browser-dot red"></span>
    <span class="browser-dot yellow"></span>
    <span class="browser-dot green"></span>
    <div class="browser-url">idp.yidong.com.tw/hr/dashboard</div>
  </div>
  <div class="browser-body">
    <h1 class="app-h1">業務二部 · IDP 進度看板</h1>
    <h2 class="app-h2">2026 Q2 · 23 人在追蹤</h2>
    <div class="kpi-num">87%</div>
    <!-- ... -->
  </div>
</div>
```

關鍵 mockup vocabulary：
- `.browser-frame` — Chrome window 樣式
- `.browser-url` — URL bar（mono 字、灰底）
- `.app-h1 / .app-h2` — App 內標題
- `.kpi-num` — 大型數字
- `.pill / .pill-warn` — 狀態標籤
- `.spec-row` — 表單欄位

## 章節編號規則

```
00 · Foreword          (cover 立場)
01 · System Map        (角色 / 權限 / 流程地圖)
02 · Functional Spec   (功能規格，Part 1/2/3 拆頁)
03 · Pricing & Terms   (報價 / 維運 / 付款 / 市場對比)
04 · Why Us            (團隊 / 案例 / 為什麼是這個價格)
05 · Next Step         (CTA / 結尾)
Visual 01-07           (Part 2 視覺章節)
Appendix               (技術分類 / 詞彙表)
```

label 一律「`{編號} · {英文章節名} · {子題}`」格式，中英混排製造印刷感。

## 不要做的事（從製造業客戶案踩過的坑）

- ❌ 不要 PPT 風格（陰影、漸層、玻璃擬態）— 這是印刷品不是簡報
- ❌ 不要用 emoji 當裝飾（除 ⭐ 主推徽章）— 削弱專業感
- ❌ 不要彩虹色 brand palette — 6-7 色 brand-locked，超過會亂
- ❌ 不要中央對齊大段文字 — 段落左對齊，視覺穩定
- ❌ 不要 `line-height` < 1.6（中文）— 擠
- ❌ 不要 padding < 60px（A4 左右） — 顯小氣
- ❌ 不要把「不含」用紅色大字 — 用 muted/rust 小字即可
- ❌ 不要章節之間「直接接內容」— 一定要 cover 頁過渡
- ❌ 不要對外露 v1.X / Draft / 修訂版 字眼
- ❌ 不要寫死「後 X 頁」「第 Y 頁」— 內容增刪會錯

## 完整 CSS 起手樣板

完整 `<style>` block 範本見：
`feature9_yidong_idp/02_需求書/製造業客戶人事顧問_IDP線上化系統_提案書.html` 第 1-220 行

下次接案直接 copy 整個 CSS block，改 brand 顏色（gold 換成案件主色）即可。

## 對應 build 腳本

`_scripts/_build_official.py` 已包含：
- Playwright A4 full-bleed 渲染
- fitz 後處理金色頁碼（深底/淺底自動切色）
- 三類 QA（溢位 / 孤兒頁 / 寫死頁碼）

下次接案 copy 過去、改 HTML/PDF 路徑常數即可用。
