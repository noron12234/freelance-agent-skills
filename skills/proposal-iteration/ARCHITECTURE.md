# 需求書/提案書 標準架構（5-Part Structure）

> 沉澱自製造業客戶 v1.4（40 頁）。下次接案產需求書直接套用。

## 整體骨架

```
[PROLOG]     00 封面（hero）
             01 Foreword（為什麼是這份文件 · 立場 framing）

[PART 1]     系統規格全貌（System Spec · 技術深度）
             ├─ 系統地圖 / 角色權限矩陣
             ├─ 多重角色設計
             ├─ 7 張表單規格（拆多頁）
             ├─ 自動化流程 / 12 個月時間軸
             └─ 數據儀表板 / 服務範圍與權責

[PART 2]     視覺答覆（Visual Answer · 讓客戶看見）
             ├─ Visual 01 學員視角（UI mockup）
             ├─ Visual 02 主管視角
             ├─ Visual 03 HR 後台
             ├─ Visual 04 (SaaS) 跨企業管理視角 ⭐
             ├─ Visual 05 教練/外部角色回饋
             ├─ Visual 06 三平台 RWD（手機/平板/桌機）
             └─ Visual 07 報告與通知範例（Email/LINE/月報）

[PART 3]     商業價值（Business Value · 賣 ROI）
             ├─ 為什麼這套系統值（3 個 ROI 角度）
             ├─ 對比 in-house dev 成本
             └─ 平台事業的可能（未來擴展）

[PART 4]     報價 + 條款（Pricing & Terms · 決策資訊）
             ├─ A/B/C 三方案總覽（含核心區別）
             ├─ A 故事頁 / B 故事頁 / C 故事頁（各自獨立頁）
             ├─ 三方案比較表
             ├─ 加急選項（×1.25-1.5）
             ├─ 維運級別（建議搭配 A/B/C）
             ├─ 付款方式（40/30/30 或 30/40/30）
             ├─ 市場價格對比（anchor）
             └─ 為什麼是這個價格（次元創意的工法）

[EPILOG]     Next Step（下一步只有一件事 + 三方案回顧）
             結尾頁（End of Document · 案件編號 · 下一里程碑）
             Appendix（技術分類定義 / MAP 冰山等）
```

## 階段 mapping → gen-* skill

| Part | 對應 skill | 適用 stage |
|---|---|---|
| PROLOG + PART 1 only | `/gen-discovery-doc` | Stage 0 · 需求未明 |
| PROLOG + PART 1 + PART 2 | `/gen-demo-proposal` | Stage 1 · 對齊想像 |
| PROLOG + PART 1+2+3+4 | `/gen-pricing-proposal` | Stage 2 · 會議用 |
| 13 頁濃縮版 + CTA | `/gen-deal-doc` ⭐ | Stage 3 · 催簽約 |
| 合約 HTML | `/gen-contract` | Stage 4 · 簽約 |

## 章節頁面長度估算（製造業客戶 實測）

| 區塊 | 頁數 | 備註 |
|---|---|---|
| 封面 + Foreword | 2 | 開場 |
| Part 1 章節 cover + 規格 | 12 | 含拆頁避免孤兒 |
| Part 2 章節 cover + Visuals | 8 | 每個 Visual 0.5-1 頁 |
| Part 3 商業價值 | 3-4 | |
| Part 4 報價 + 條款 | 10 | A/B/C 各 1 頁 + 比較 + 維運 + 付款 + 市場對比 |
| Next Step + 結尾 | 2 | |
| Appendix | 2-3 | 可選 |
| **總計** | **~40 頁** | 完整提案規格 |

`gen-deal-doc` 是濃縮版：12-13 頁、跳過 Visual mockup、保留 Part 1 精華 + Part 3+4 + 強 CTA。

## 章節間的敘事節奏

每個 Part 之間用「**章節 cover 頁**」過渡（深底大字 serif）：
```
ink 深背景 + grid-bg 細網紋 + 巨大 PART X · TITLE serif 標題
+ 一句話描述「這一章節給您 ___」
+ 「若想直接看畫面，可以先跳到 Part 2 視覺章節」（不寫死頁數）
```

這個節奏感模仿 magazine editorial：
- 章節 cover = 緩衝 + 蓄勢
- 內容頁 = 規格表、文字解說
- Visual 頁 = 大圖 mockup
- 報價頁 = 三欄卡片
- 黑底 highlight box = 重要結論 / 殺手條款 / CTA

## 每章節的「黃金開頭」公式

每頁頂部都用同一個格式打底，建立節奏感：
```html
<div class="label">02 · Functional Spec · Part 1</div>
<div class="h-rule mt-3 mb-12"></div>

<h2 class="serif text-3xl mb-3">章節主標</h2>
<p class="text-[15px] mb-10" style="max-width:640px;">
  一句話定位這個章節在解什麼問題。
</p>

<!-- 主內容 -->
```

label 是「麵包屑」性質的章節標籤，h-rule 是水平分隔線，標題用 serif 大字。客戶翻頁立刻知道「現在在哪一章」。

## 必有的 7 種「賣方法論」段落

1. **「為什麼是這份文件」** — Foreword 立場 framing（不是報價單、是組裝給你看）
2. **「適合您 if / 不適合您 if」** — 在 A/B/C 方案頁，主動 disqualify 不對的客戶
3. **「為什麼推薦 B」** — 主推方案的論述（光列功能不夠、要說「為什麼別人會選」）
4. **「為什麼加急會多 25%」** — 任何溢價條款都要主動解釋（讓客戶覺得透明）
5. **「為什麼是 40/30/30」** — 付款分期的雙方權責邏輯
6. **「為什麼這個價格」** — 對比市場 / 對比 in-house dev / 對比同類 SI
7. **「合約週期」** — 不綁約 / 一年一簽 / 30 天前可換（降低承諾恐懼）

每個段落都用淺色 box（cream 背景 + gold 左邊框）框起來，視覺上就是「這裡有重要說明、不要跳過」。
