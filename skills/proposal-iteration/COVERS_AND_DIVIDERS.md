# 封面 / 結尾頁 / 章節 Cover — 完整實作說明書

> 三種「特殊頁」的完整 HTML + CSS + 視覺說明，下次接案 copy-paste 改變數即可。
> 沉澱自製造業客戶 v1.4 對外正式版。

---

## 必要 CSS（任何案件都要先放入 `<style>`）

```css
:root {
  --ink:       #0E1A1F;
  --ink-2:     #364046;
  --line:      #E5E1D8;
  --cream:     #F7F4ED;
  --paper:     #FBFAF6;
  --gold:      #B8956A;
  --gold-deep: #8B6E3A;
  --teal:      #1F4742;
  --rust:      #A84F2C;
  --muted:     #6B7378;
}

/* 三類特殊頁共用的 class */

.serif        { font-family: 'Noto Sans TC','Inter',serif; font-weight:700; }
.num-display  { font-family: 'Inter'; font-weight:200; font-feature-settings:"tnum" 1; }

.label {
  font-size: 11px;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: var(--gold-deep);
  font-weight: 600;
}

.h-rule       { height:1px; background:var(--ink); opacity:0.85; }
.h-rule-gold  { height:2px; background:linear-gradient(90deg,var(--gold) 0%,transparent 100%); }

.grid-bg {
  background-image:
    linear-gradient(rgba(14,26,31,0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(14,26,31,0.03) 1px, transparent 1px);
  background-size: 24px 24px;
}

.marker-gold  { color:var(--gold-deep); font-weight:600; }

/* 章節 cover 專用（部位深底 + 金色 label）*/
.part-divider { background: var(--ink); color: var(--cream); }
.part-divider .part-label {
  color: var(--gold);
  font-size: 12px;
  letter-spacing: 0.3em;
  text-transform: uppercase;
}
```

**重要**：所有特殊頁都用 `.page` class 撐滿 A4，且用 `display:flex; flex-direction:column; justify-content:space-between` 或 `justify-content:center` 分配內容。

---

# 一、封面（Cover · p1）

## 視覺結構（ASCII 示意）

```
┌────────────────────────────────────────────────────────┐
│ FULL PROPOSAL · 規格 + 視覺 + ...     次元創意 × {客戶}  │ ← 頂部 label 對齊
│ ────────────────────────────────────────────────       │ ← h-rule（淡黑線）
│                                                        │
│  (大量空白製造呼吸感)                                    │
│                                                        │
│  FOR {客戶全名}                                          │ ← 小 label
│                                                        │
│  ▄▄▄▄▄ ▄▄▄▄                                            │ ← 主標 64px serif（深色）
│  ▄▄▄▄▄ ▄▄▄▄▄▄▄                                         │
│  ▄▄▄▄▄▄▄▄ ▄▄▄▄ ← 副標換金深色                          │
│  ───── ← gold 漸層短線 120px                            │
│                                                        │
│  將紙本 X 從「Y」的形式主義，                              │ ← 副描述（次要色）
│  轉化為 1-2 年陪跑式的 ...                                │
│                                                        │
│  (大量空白)                                              │
│                                                        │
│ ────────────────────────────────────────────────       │
│ Prepared by    Document Type      Pages · Engagement   │ ← 三 metadata 欄
│ 次元創意        完整提案合輯        4 大章節 · 40 頁     │
│ AI-native...   規格+視覺+商業+報價  2-5 個月開發+維運    │
└────────────────────────────────────────────────────────┘

      整頁背景：paper 紙色 + grid-bg 細網紋（24px × 24px）
```

## 完整 HTML 模板（copy 改 5 個變數）

```html
<!-- ========== 封面 ========== -->
<section class="page grid-bg" style="min-height: 100vh; display:flex; flex-direction:column; justify-content:space-between;">

  <!-- 頂部：兩個 label + h-rule -->
  <div>
    <div class="flex items-center justify-between">
      <div class="label">Full Proposal · 規格 + 視覺 + 商業價值 + 報價</div>
      <div class="label">次元創意 × {客戶簡稱}</div>
    </div>
    <div class="h-rule mt-3"></div>
  </div>

  <!-- 中央：For + 主標 + 副描述 -->
  <div class="my-12">
    <div class="label mb-6">For {客戶全名}</div>
    <h1 class="serif" style="font-size:64px; line-height:1.1; letter-spacing:-0.02em; font-weight:800;">
      {專案主標題 line 1}<br>
      {專案主標題 line 2}<br>
      <span style="color:var(--gold-deep);">{副標題 · 用 gold-deep 染色}</span>
    </h1>
    <div class="h-rule-gold mt-10" style="width:120px;"></div>
    <p class="mt-10 text-lg" style="color:var(--ink-2); line-height:1.85; max-width:560px;">
      {一句話描述：要解什麼問題}，<br>
      <strong>{深層價值 · 一句話定位}</strong>。
    </p>
  </div>

  <!-- 底部：三 metadata 欄 -->
  <div>
    <div class="h-rule mb-6"></div>
    <div class="grid grid-cols-3 gap-12 text-sm">
      <div>
        <div class="label mb-2">Prepared&nbsp;by</div>
        <div class="serif text-base">次元創意</div>
        <div style="color:var(--muted); font-size:12px;">AI-native Software Studio</div>
      </div>
      <div>
        <div class="label mb-2">Document&nbsp;Type</div>
        <div class="serif text-base">完整提案合輯</div>
        <div style="color:var(--muted); font-size:12px;">規格 + 視覺 + 商業 + 報價</div>
      </div>
      <div>
        <div class="label mb-2">Pages · Engagement</div>
        <div class="serif text-base">{N} 大章節 · {實際頁數} 頁</div>
        <div style="color:var(--muted); font-size:12px;">{工期} + 長期維運</div>
      </div>
    </div>
  </div>

</section>
```

## 變數填空表

| 變數 | 製造業客戶 範例 | 線上課程客戶範例 |
|---|---|---|
| `{客戶簡稱}` | 製造業客戶人事顧問 | 學習家 線上課程客戶 |
| `{客戶全名}` | 製造業客戶人事顧問股份有限公司 | 學習家股份有限公司 |
| `{專案主標題 line 1}` | MAP IDP | 線上課程客戶 實戰學院 |
| `{專案主標題 line 2}` | 個人發展計畫 | 招生與學員入口 |
| `{副標題 gold-deep}` | 線上化系統 | 官網建置 |
| `{要解什麼問題}` | 將紙本 IDP 從「寫完就丟」的形式主義 | 把舊版半年班網頁升級為實戰學院主力招生站 |
| `{深層價值}` | 1–2 年陪跑式的長期追蹤管理系統 | 4 週交付、即上線即招生 |
| `{N} 大章節` | 4 大章節 | 5 大章節 |
| `{實際頁數}` | 40 頁 ⚠️ 必須 match PDF 真實頁數 | 13 頁 |
| `{工期}` | 2 – 5 個月開發 | 4 週 |

## 視覺要點

- **font-size:64px** 主標 — 別小於 56px（這是 hero 比重）
- **letter-spacing:-0.02em** 主標緊密 — 緻密 modern 感
- **font-weight:800** 主標粗體 — 視覺份量
- **副標換 gold-deep 色** — 通常是「線上化系統 / 官網建置」等動詞性結尾
- **h-rule-gold 120px** 短金色漸層 — 視覺重量錨點
- **max-width:560px** 副描述限寬 — 中文行寬控制
- **三 metadata 欄** 等距 grid-cols-3 — 印刷感

## 對外送出前自我檢查

- [ ] 沒有 v / Draft / 修訂版 / 日期 字眼
- [ ] 客戶全名拼字正確（股份有限公司 / 有限公司 / 工作室 分清楚）
- [ ] 「Pages」數字 = PDF 實際頁數
- [ ] 主標換行斷在自然語意點（不要硬切詞）

---

# 二、結尾頁（End of Document · 最後 1 頁）

## 視覺結構

```
┌────────────────────────────────────────────────────────┐
│ END OF DOCUMENT                  次元創意 × {客戶}      │ ← 金色 label（深底）
│ ────────────────────────────────────────────────       │ ← 半透明 cream 線
│                                                        │
│  (大量空白)                                              │
│                                                        │
│  PRESENTED BY                                            │ ← 金色 label
│                                                        │
│  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ← cream 白色大字 60px serif             │ ← 主體：公司名
│  次元創意有限公司                                          │
│  Dimension Creative Co., Ltd. ← 金色 num-display 18px   │
│  ───── ← gold 漸層短線 140px                             │
│                                                        │
│  此份文件由次元創意團隊為                                  │ ← cream 85% 透明
│  {客戶全名} 量身組裝，                                     │ ← 客戶名用金色 strong
│  涵蓋完整規格、視覺、商業價值與報價。                       │
│  確認檔位後，5 個工作天內出合約草案。                       │
│                                                        │
│  (大量空白)                                              │
│                                                        │
│ ────────────────────────────────────────────────       │ ← 半透明 cream 線
│ 案件編號         文件性質         下一里程碑              │ ← 金色 label
│ F09 · IDP       完整提案         合約草案 · 5/21 前      │ ← cream 白色 serif
│ 2026 — Active   規格+視覺+報價    確認檔位後啟動           │ ← 半透明 num
│                                                        │
│ ────────────────────────────────────────────────       │
│ CONFIDENTIAL · 僅供雙方使用      © 2026 Dimension      │ ← 50% 透明 cream
└────────────────────────────────────────────────────────┘

      整頁背景：ink 深色 + grid-bg 細網紋（暗紋）
```

## 完整 HTML 模板（copy 改 6 個變數）

```html
<!-- ========== 結尾頁 · Endpage（深底） ========== -->
<section class="page grid-bg" style="background:var(--ink); color:var(--cream); min-height:100vh; display:flex; flex-direction:column; justify-content:space-between;">

  <!-- 頂部：End of Document label + 半透明線 -->
  <div>
    <div class="flex items-center justify-between">
      <div class="label" style="color:var(--gold);">End of Document</div>
      <div class="label" style="color:var(--gold);">次元創意 × {客戶簡稱}</div>
    </div>
    <div class="h-rule mt-3" style="background:var(--cream); opacity:0.25;"></div>
  </div>

  <!-- 中央：PRESENTED BY 大字主體 -->
  <div class="my-12">
    <div class="label mb-8" style="color:var(--gold);">PRESENTED BY</div>
    <h1 class="serif" style="font-size:60px; line-height:1.05; letter-spacing:-0.02em; font-weight:800; color:var(--cream);">
      次元創意有限公司
    </h1>
    <p class="num-display mt-3" style="font-size:18px; color:var(--gold); font-weight:300; letter-spacing:0.08em;">
      Dimension Creative Co., Ltd.
    </p>
    <div class="h-rule-gold mt-10" style="width:140px;"></div>
    <p class="mt-10" style="font-size:15px; color:var(--cream); opacity:0.85; line-height:1.9; max-width:560px;">
      此份文件由次元創意團隊為<br>
      <strong style="color:var(--gold); font-weight:600;">{客戶全名}</strong> 量身組裝，<br>
      涵蓋完整規格、視覺、商業價值與報價。確認檔位後，5 個工作天內出合約草案。
    </p>
  </div>

  <!-- 底部：三 metadata 欄 + CONFIDENTIAL -->
  <div>
    <div class="h-rule mb-8" style="background:var(--cream); opacity:0.25;"></div>
    <div class="grid grid-cols-3 gap-10 text-sm" style="margin-bottom:12px;">
      <div>
        <div class="label mb-2" style="color:var(--gold);">案件編號</div>
        <div class="serif" style="color:var(--cream); font-size:16px;">{F0X · 代號}</div>
        <div class="num-display mt-1" style="font-size:11px; color:var(--cream); opacity:0.55;">2026 — Active</div>
      </div>
      <div>
        <div class="label mb-2" style="color:var(--gold);">文件性質</div>
        <div class="serif" style="color:var(--cream); font-size:16px;">完整提案</div>
        <div class="num-display mt-1" style="font-size:11px; color:var(--cream); opacity:0.55;">規格 + 視覺 + 報價</div>
      </div>
      <div>
        <div class="label mb-2" style="color:var(--gold);">下一里程碑</div>
        <div class="serif" style="color:var(--cream); font-size:16px;">合約草案 · {M/D} 前</div>
        <div class="num-display mt-1" style="font-size:11px; color:var(--cream); opacity:0.55;">確認檔位後啟動</div>
      </div>
    </div>

    <div class="h-rule mt-10" style="background:var(--cream); opacity:0.25;"></div>
    <div class="flex items-center justify-between mt-4" style="font-size:10.5px; color:var(--cream); opacity:0.5; letter-spacing:0.08em;">
      <span>CONFIDENTIAL · 本文件僅供次元創意與{客戶簡稱}之間使用，請勿轉交第三方</span>
      <span class="num-display">© 2026 Dimension Creative</span>
    </div>
  </div>

</section>
```

## 變數填空表

| 變數 | 製造業客戶 範例 |
|---|---|
| `{客戶簡稱}` | 製造業客戶人事顧問（或更短：製造業客戶）|
| `{客戶全名}` | 製造業客戶人事顧問股份有限公司 |
| `{F0X · 代號}` | F09 · IDP（feature9_yidong_idp）|
| `{M/D}` | 5 / 21（合約草案截止日）|

## 為什麼結尾頁是深底（重要設計邏輯）

整本書架構是 **paper 淺底（主體）→ ink 深底（封閉）**：
- 封面 = paper 淺底（開場輕、引導往內）
- 中間 N 頁 = paper 淺底（內容呼吸）
- **章節 cover** = ink 深底（過渡 + 蓄勢）
- **結尾頁** = ink 深底（**閉合 · 印章效果**）

像書本的精裝硬殼結尾 — 深底頁傳達「文件結束、莊重簽收」的視覺心理。

## 對外送出前自我檢查

- [ ] 「PRESENTED BY」+「公司名」+「英文」三件一組
- [ ] 「文件性質」**不要寫**「Draft / v1.X / 修訂版 / 待客戶回饋迭代」
- [ ] 「下一里程碑」寫**「合約草案 · M/D 前」**，不寫「修訂版」
- [ ] 「確認檔位後啟動」是固定句，不要加日期
- [ ] CONFIDENTIAL 寫「**僅供…使用**」，不寫「提案草案」「需求書草稿」

---

# 三、章節 Cover 頁（Part Divider · 每章節之間）

## 用途

每個 Part（PART 1 規格 / PART 2 視覺 / PART 3 商業價值 / PART 4 報價）之間都用「章節 cover 頁」過渡 — 1 頁深底大字，作為敘事節奏的緩衝。

**為什麼必要**：
- 客戶翻到深底頁會自動「停頓」一下 — 切換思維模式（從規格腦切到視覺腦）
- 印刷品的標準節奏 — 沒有 cover 頁 = 像 PPT、不像文件
- 避免「兩個不同 Part 的內容頁直接相鄰」的視覺衝突

## 視覺結構

```
┌────────────────────────────────────────────────────────┐
│ (大量空白 · 整頁置中)                                    │
│                                                        │
│  PART 1 · SYSTEM SPEC                                   │ ← 金色 part-label
│                                                        │   12px / spacing 0.3em
│  ▄▄▄▄ ← cream 白色大字 60px serif                       │
│  系統                                                    │
│  ▄▄▄▄▄▄ ← span 換金色                                   │
│  規格全貌                                                │
│                                                        │
│  ─────── ← gold 漸層短線 120px · 60% 透明              │
│                                                        │
│  角色權限矩陣、7 張表單規格、12 個月 ...                  │ ← cream 85% 透明
│  — 這是技術深度的部分                                     │
│                                                        │
│  若想直接看畫面，可以先跳到 Part 2 視覺章節 ...           │ ← 55% 透明小字
│                                                        │
│ (大量空白)                                              │
└────────────────────────────────────────────────────────┘

      整頁背景：ink 深色 + grid-bg 細網紋
      內容垂直置中（justify-content:center）
```

## 完整 HTML 模板

```html
<!-- ========== Part X 標題頁 ========== -->
<section class="page part-divider grid-bg" style="min-height:100vh; display:flex; flex-direction:column; justify-content:center;">

  <!-- 上方 part 標籤 -->
  <div class="part-label mb-6">Part {N} · {English Title}</div>

  <!-- 中央大標（兩行 + 換色強調） -->
  <h2 class="serif" style="font-size:60px; line-height:1.15; letter-spacing:-0.02em; color:var(--cream);">
    {中文大標 line 1}<br>
    <span style="color:var(--gold);">{中文大標 line 2 · 強調}</span>
  </h2>

  <!-- 金色短分隔線 -->
  <div class="h-rule-gold mt-12 mb-8" style="width:120px; opacity:0.6;"></div>

  <!-- 引言段 -->
  <p class="text-lg" style="color:var(--cream); opacity:0.85; line-height:1.85; max-width:560px;">
    {章節重點 1}、{章節重點 2}、{章節重點 3} — <strong style="color:var(--gold);">{一句話定位}</strong>。
  </p>

  <!-- 底部小字導引 -->
  <div class="mt-12 text-[12px]" style="color:var(--cream); opacity:0.55; line-height:1.7;">
    {跳章引導 / 預告 / 視覺概念稿說明}
  </div>

</section>
```

## 4 個 Part 的填空對照（製造業客戶）

### Part 1 · System Spec
```
part-label:  Part 1 · System Spec
大標 line 1: 系統
大標 line 2: 規格全貌（gold 強調）
引言:        角色權限矩陣、7 張表單規格、12 個月自動觸發點、數據儀表板、
            服務範圍與權責劃分 — 這是技術深度的部分。
底部小字:    若想直接看畫面，可以先跳到 Part 2 視覺章節，看完視覺後再回頭看細節。
```

### Part 2 · Visual Answer
```
part-label:  Part 2 · Visual Answer
大標 line 1: 您每天
大標 line 2: 會看到 (br) 什麼？（gold 強調）
引言:        規格寫完了，但您可能仍想問：「實際打開瀏覽器，我看到什麼？」
            這一章節給您具體視覺答案 — 5 個角色介面、12 個月時間軸、
            月度報告與 Excel 範例、三平台 RWD。
底部小字:    所有介面為視覺概念稿（concept mockup） · 實際細節依您回饋微調 ·
            但版型、互動流、資料層次會與此一致。
```

### Part 3 · 商業價值
```
part-label:  Part 3 · Business Value
大標 line 1: 您會
大標 line 2: 得到什麼？（gold 強調）
引言:        把 HR 30% 時間救出來、為 1-2 年累積資料、為平台事業舖路 —
            這是 ROI 的部分。
底部小字:    我們不會用「降低成本」、「提升效率」這種空話 — 直接用數字算給您看。
```

### Part 4 · 報價 + 條款
```
part-label:  Part 4 · Pricing & Terms
大標 line 1: 多少錢、
大標 line 2: 怎麼合作？（gold 強調）
引言:        A 電子化 / B 自動化 ⭐ / C 平台化 三檔位報價、加急選項、
            維運與付款、市場價格對比、我們的團隊與相近案例、為什麼是這個價格。
底部小字:    決定方案前可任意提問 — 我們的目標是您「100% 知道自己在買什麼」。
```

## 章節 cover 頁的設計規則（硬性）

1. **永遠用 `.part-divider .grid-bg`** — ink 深底 + grid 暗紋
2. **永遠垂直置中** `justify-content:center`（不是 space-between）
3. **大標永遠 60px、serif、letter-spacing:-0.02em**
4. **大標永遠拆兩行**，第二行用 `<span style="color:var(--gold);">` 染金
5. **金色短線永遠 120px、60% opacity**（不要 100%、太搶眼）
6. **引言段永遠 max-width:560px、cream 85% opacity**
7. **底部小字永遠 12px、cream 55% opacity** — 給「跳章導引」或「視覺概念稿說明」

## 為什麼每個元素都要 opacity？

深底頁面上**純 cream 白色文字會過於搶眼**，所有文字都要降低透明度製造層次：
- 大標 → 100%（最重要）
- 副標 / 引言 → 85%（次重要）
- 底部小字 → 55%（最輕，但仍可讀）

這是 Editorial print 的標準做法 — 不是設計感、是可讀性層次。

## 章節 cover 之間的順序

完整需求書的章節 cover 出現順序：

```
封面（淺底）
   ↓
00 Foreword（淺底內容頁）
   ↓
📕 PART 1 cover（深底）← 章節 1
01 系統地圖（淺底）
02 功能規格（淺底）
...
   ↓
📕 PART 2 cover（深底）← 章節 2
Visual 01 ~ 07（淺底）
   ↓
📕 PART 3 cover（深底）← 章節 3
商業價值 ROI 1/2/3（淺底）
   ↓
📕 PART 4 cover（深底）← 章節 4
報價 + 維運 + 付款 + 市場 + About + Why Us（淺底）
   ↓
05 Next Step（淺底）
   ↓
📕 結尾頁（深底）← 閉合
```

每兩個 Part 之間 = 1 個深底 cover 頁。整本書深底頁總計 5 個（4 個 part cover + 1 個結尾）。

⚠️ 深底頁不要過多 — 5 個是上限，再多會讓書「太重」。

---

# 四、三類深底頁的對比速查

| 屬性 | 封面 | 章節 cover | 結尾頁 |
|---|---|---|---|
| 背景 | paper 淺底 + grid-bg | **ink 深底** + grid-bg | **ink 深底** + grid-bg |
| 垂直分布 | space-between（頂中底）| **center（垂直置中）** | space-between |
| 主標 size | 64px | 60px | 60px |
| 主標 weight | 800 | 700 (.serif 預設) | 800 |
| 主標換色 | 第 3 行用 gold-deep | 第 2 行用 gold | 全 cream（公司名不染色） |
| h-rule-gold 寬 | 120px | 120px / 60% opacity | 140px |
| 底部三 metadata | Prepared / Doc Type / Pages | （無）| 案件編號 / 文件性質 / 下一里程碑 |
| 是否有 CONFIDENTIAL | 否 | 否 | **是**（底部小字）|
| 出現位置 | p1 | 每章節間（× 4 個 Part）| 最後 1 頁 |
| 跳過頁碼 | ✅（fitz 跳過）| ❌（有頁碼）| ❌（有頁碼）|

---

# 五、實作範例索引

實際 HTML 完整實作：
- **製造業客戶（Track A · 系統案）**
  - 封面：`feature9_yidong_idp/02_需求書/製造業客戶..._提案書.html` 第 225-269 行
  - Part 1 cover：第 334-348 行
  - Part 2 cover：第 1011-1027 行
  - 結尾頁：第 2716-2770 行

- **線上課程客戶（Track B · 前端網頁案）**
  - 封面：`feature{N}_client_project/02_提案報價/proposal_v4_需求書_demo.html`

對應 PDF 視覺效果可直接打開檔案看。

---

# 六、不可省略的設計細節（容易踩坑）

## 字體 fallback
```css
font-family: 'Noto Sans TC','Inter',serif;
```
Noto Sans TC 在前 → 中文用 Noto、英文/數字自動 fallback 到 Inter。**順序不可顛倒**，顛倒會讓中文用 Inter（缺字會變方塊）。

## grid-bg 的精準參數
```css
linear-gradient(rgba(14,26,31,0.03) 1px, transparent 1px);
background-size: 24px 24px;
```
- opacity 必須 0.03（淺底頁）/ 配深底頁時自動更淡
- size 24px 是黃金值 — 16px 太密像方格紙、32px 太疏失存在感

## h-rule-gold 的漸層
```css
background: linear-gradient(90deg, var(--gold) 0%, transparent 100%);
```
**永遠左濃右淡**（不是中央漸層）— 視覺起點明確、向右消散符合閱讀方向。

## flex 結構必須 `min-height: 100vh`
深底頁如果不用 `100vh` 撐滿，會出現「下半部漏出下一頁背景」的視覺破洞。**必加 `min-height: 100vh`**。

## 中文 letter-spacing 永遠負值
`-0.01em ~ -0.02em` — 中文大字會自動「字距過寬」，加負值才有 modern 感。**英文不要加**（會擠成一團）。
