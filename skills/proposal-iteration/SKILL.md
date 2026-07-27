---
name: proposal-iteration
description: 提案書 / 需求書 / 合約 HTML→PDF 的完整迭代流程 SOP — 涵蓋版本管理（內部 v1.X / 對外無版號雙軌）、資料夾架構、客戶回饋對應、報價結構（A/B/C anchor）、CTA 設計、對外語氣紀律（11 個必清字眼）、PDF 三類 QA（溢位/孤兒頁/寫死頁碼）、頁碼系統。當用戶在做案件提案改版、抱怨「客戶會看到第幾版」「PDF 頁不對」「孤兒頁」「報價要再升級」等情境時觸發。沉澱自 2026-05 製造業客戶 案 v1.0→v1.4 完整實戰。
---

# 與 gen-* commands 的關係

本 skill = **「需求書生產線的底層方法論」**，不直接生 doc。實際產 doc 用 `.claude/commands/gen-*` 進入：

```
[情境入口 commands]                       [本 skill · 底層方法論]
────────────────────                      ──────────────────────
/gen-discovery-doc   (探索型，需求未明)    ┐
/gen-demo-proposal   (Demo 視覺型)        ├──→  ARCHITECTURE.md
/gen-pricing-proposal (三方案報價)       ├──→  FULL_BREAKDOWN.md
/gen-deal-doc        (成交決定型)        ├──→  COMPANY_INTRO.md
/gen-contract        (合約)              ├──→  CHAPTER_TEMPLATES.md
                                          ├──→  COVERS_AND_DIVIDERS.md
                                          ├──→  DESIGN_SYSTEM.md
                                          └──→  CHECKLIST.md
```

每個 gen-* command 開頭都有「⚠️ 開始寫之前必讀」block 指向本 skill 對應檔案。**反向看本 skill 被呼叫時要載入哪些**：

| 進入點 command | 主要載入檔（本 skill）|
|---|---|
| `/gen-discovery-doc` | ARCHITECTURE / CHAPTER §1-§2 / FULL_BREAKDOWN §1-§7 / COVERS / DESIGN / CHECKLIST |
| `/gen-demo-proposal` | ARCHITECTURE / CHAPTER §3 / FULL_BREAKDOWN §8-§10 / COVERS / DESIGN / CHECKLIST |
| `/gen-pricing-proposal` ⭐ | **全部 7 檔載入**（製造業客戶 40 頁等級的完整提案）|
| `/gen-deal-doc` | COMPANY_INTRO / CHAPTER（重點 §7 信任建立）/ COVERS / DESIGN / CHECKLIST |
| `/gen-contract` | CHAPTER §7（服務承諾）/ DESIGN / CHECKLIST I 對外語氣紀律 |

⚠️ **不要把本 skill 內容複製到 gen-* commands** — 雙來源同步難。所有方法論細節留在本 skill，gen-* commands 只負責「情境判斷 + 呼叫對應章節」。

---

# 觸發場景

對話出現以下訊號就主動套用本 SOP：

| 訊號 | 動作 |
|---|---|
| 「整理需求書」「版本好亂」 | 套 §1 雙軌命名 + §2 資料夾架構 |
| 「客戶不能看到第幾版」「對外要拿掉版號」 | 套 §3 對外語氣紀律 + 11 點檢查表 |
| 「PDF 有溢位 / 孤兒頁 / 第 X 頁怪怪的」 | 套 §5 PDF QA 三件套 |
| 「報價要升級」「想長期賺錢」「給客戶選擇權」 | 套 §4 A/B/C anchor 結構 + 6 槓桿 recurring |
| 「客戶回饋來了」 | 寫進 `99_其他/v{X}_a_需修正內容.md`、產新版進 `_versions/` |
| 「正式對外送出」 | 跑 §6 送出前必檢清單 |

---

# §1 版本命名雙軌制

## 內部
- 格式：`v{major}.{minor}_{性質}_{MMDD}.{html|pdf}`
- 範例：`v1.4_完整提案_0518.pdf`
- 全部進 `_versions/` 子資料夾

## 對外
- 格式：`{客戶全名}_{產品全名}_{文件類型}.pdf`
- 範例：`製造業客戶人事顧問_IDP線上化系統_提案書.pdf`
- 主層只放一份（永遠是最新版的副本，覆寫）
- **絕對不可帶版號、日期、Draft、v、修訂版字眼**

## Why
客戶看見「v1.4」會聯想「他改了 4 次、之前一定很爛、他還沒定稿、我可以再要他改」 → 削弱專業信任、增加殺價籌碼。

---

# §2 資料夾架構（標準 4 層）

```
feature{N}_{案件代號}/
├── AGENTS.md / AGENT_HANDOFF.md       ← 跨 agent onboarding（接手必看）
├── 01_客戶資訊/                          ← 客戶提供素材 + 客戶資訊_X.md + 會議記錄_X.md
├── 02_需求書/                            ← 主要工作區
│   ├── README.md                       ← 版本演進表 + 命名規則 + 對外紀律
│   ├── {客戶}_{產品}_提案書.html/.pdf     ⭐ 對外正式版
│   ├── {客戶}_{產品}_Demo視覺包.html/.pdf  ⭐ 對外 Demo
│   ├── _scripts/_build_official.py     ← Build + 頁碼 + QA
│   ├── _versions/                      ← v1.0 ~ v1.X 全保留
│   └── _archive/                       ← 舊命名、早期備份、舊腳本
├── 03_合約/                              ← 簽約後
└── 99_其他/
    ├── v{X}_a_需修正內容.md              ← 每版的客戶回饋對應
    ├── 報價邏輯說明書_MMDD.md            ← 內部報價計算
    └── v{X+1}_xxx升級提案.md             ← 內部下一版方向（未送客戶）
```

---

# §3 對外語氣紀律 — 11 個必清字眼

對外送出前 grep：

```bash
grep -niE "v[0-9]\.|draft|草案|草稿|修訂版|提供中|TBD|待補|@example|xxx|fixme" *.html
```

**全文清洗對照表**：

| 內部寫法 | 對外改成 |
|---|---|
| `<title>需求設定書 v1` | `<title>完整提案` |
| 「這份 v1 文件」 | 「這份文件」 |
| 「v1 草案，待您回饋出修訂版」 | 「涵蓋完整規格、視覺、商業價值與報價」 |
| 文件狀態：v1 · Draft | 文件性質：完整提案 |
| 下一里程碑：修訂版 · X/X 前 | 下一里程碑：合約草案 · X/X 前 |
| 「5 個工作天內出修訂版」 | 「5 個工作天內出具合約草案」 |
| 「待客戶回饋迭代」 | 「規格 + 視覺 + 報價」 |
| 提案草案（CONFIDENTIAL 底部）| 本文件 |
| LINE：@xxx（提供中） | （拿掉整欄，不留 TBD） |
| 封面「N 頁」寫死的數字 | 同步實際 PDF 頁數 |
| 「Part 2 在後 8 頁」 | 「先跳到 Part 2 視覺章節」（不依賴頁碼） |

---

# §4 報價結構 — A/B/C anchor + 6 槓桿 recurring

## 基本三方案

| 方案 | 用途 | 月費 |
|---|---|---|
| A · 經濟版 | 預算優先 | 8–12K/月 |
| **B · 推薦** ⭐ | 90% 客戶 | 15–22K/月（標準） |
| C · 旗艦 | 集團型 / 多分公司 | 25–38K/月（平台維運） |

## 進階：加「方案 0 · 純買斷」當 Decoy Anchor

買斷溢價 +20%（理由：一次性、無後續服務收入），但**故意反向設計**：
- ⚠️ 客戶需自備伺服器（AWS/GCP 月費自付）
- ⚠️ SSL / 備份 / 安全更新 客戶自理
- ⚠️ 30 天保固後支援按 8K/小時計費
- ⚠️ 不含上線陪同、不含教育訓練
- ⚠️ **不能宣稱「XX 承製」** ← 殺手條款（剝奪品牌背書）

→ 客戶算完發現「不維護」更貴更累，自動選 A/B。

## 長期 Recurring 6 槓桿

1. **月維護費**（被動 recurring，依方案分級）
2. **年度 AI 模組擴充包**（10–20 萬一次 + 月費 +3–8K）
3. **多分公司加購**（每加 1 個 10 萬 + 月費 +5K）
4. **資料量計費**（passive growth，超額按單份計）
5. **多年合約折扣**（簽 2 年 95 折、3 年 9 折）
6. **季度資料分析報告**（2 萬/季 add-on）

## 預期效益對比
B 客戶 3 年總收入：單一月費結構 **152 萬** → 多槓桿結構 **211 萬**（+59 萬，且第 4 年起持續）

---

# §5 PDF QA 三件套（必跑）

`_build_official.py` 自動執行：

## ① 溢位偵測
```python
rect_h = sum(b[3] - b[1] for b in page.get_text("blocks"))
if rect_h > page.rect.height:
    flag("OVERFLOW")
```

## ② 孤兒頁 / Widow 偵測
```python
if 0 < chars < 150 or 0 < rect_h < 150:
    flag("WIDOW")  # 上一頁尾段被擠出來
```

⚠️ 會有 false positive：章節 cover、表單規格頁、章節結尾頁 — 人工判斷一次。

**修法**：壓縮前一頁（黑底 box 改 inline、文字短化、移除 padding），讓尾段被吸回去。

## ③ 寫死頁數參照
```bash
grep -nE "後 [0-9]+ 頁|第 [0-9]+ 頁|頁 [0-9]+" *.html
```

每次重新 build 後驗證寫死的數字是否還對得上。**最佳做法**：直接改成「下個章節」「在 Part 2」「後面」這種不依賴頁碼的描述。

---

# §6 對外送出前必檢清單

```
□ <title> 不含 v / 需求設定書 / Draft
□ 內文無「v1 文件 / v1 草案」字眼
□ 結尾頁無 Draft / 修訂版 / 草案 / 待客戶回饋迭代
□ CTA 段寫「出具合約草案」不寫「出修訂版」
□ CONFIDENTIAL 底部寫「本文件僅供…使用」不寫「提案草案」
□ 維運費對齊：A/B/C 月費跟維運頁級別一致
□ 維運加值不寫死月費數字
□ CTA 頁無 TBD 聯絡資訊（LINE/電話「提供中」）
□ 封面頁數對得上 PDF 實際頁數
□ 內文無寫死「後 X 頁」「第 Y 頁」
□ 比較表、CTA、報價總覽的 A/B/C 數字三處一致
□ PDF 跑 _build_official.py 通過三類 QA
□ 主層 PDF 檔名無版號（{客戶}_{產品}_提案書.pdf）
□ Email 主旨 / 內文不提「v1.X」「修訂版」
```

---

# §7 頁碼系統實作

每頁右下角金色「{n:02d} / {total:02d}」，fitz 後處理（不破壞 full-bleed 設計）：

```python
def add_page_numbers(pdf_path):
    doc = fitz.open(pdf_path)
    total = len(doc)
    for i, page in enumerate(doc, 1):
        if i == 1: continue  # 封面跳過（有自訂 footer）
        # 偵測背景色：深底用亮金 / 淺底用深金
        pix = page.get_pixmap(clip=fitz.Rect(0, 0, 50, 50), dpi=30)
        avg = sum(pix.samples[:3]) / 3
        color = (0.78, 0.62, 0.32) if avg < 100 else (0.55, 0.42, 0.18)
        page.insert_text(
            fitz.Point(page.rect.width - 68, page.rect.height - 22),
            f"{i:02d} / {total:02d}",
            fontsize=8.5, color=color, fontname="helv",
        )
    # save 到 tmp 再 mv（fitz 不能 in-place）
    tmp = pdf_path.with_suffix(".tmp.pdf")
    doc.save(str(tmp)); doc.close()
    shutil.move(str(tmp), str(pdf_path))
```

完整 `_build_official.py` 範本見：
`/Users/linjunrong/Desktop/test/waiting-list/feature9_yidong_idp/02_需求書/_scripts/_build_official.py`

---

# §8 AskUserQuestion 的時機

**必問**（影響商務決策）：
- Merge 策略（覆蓋 / 換掉 / 並存）
- 報價數字（買斷溢價 % / 月費分級 / 主賣點是什麼）
- 大方向結構升級（從 A/B/C 變 0/A/B/C 要不要做）

**不問直接做**（純執行）：
- 清「v / 草案 / Draft / TBD」字眼
- 壓孤兒頁
- 改檔名（去版號）
- 修數字一致性
- 加頁碼

---

# §9 跨 Agent 協作（GitHub merge 場景）

若有外部 agent 在做平行版本（GitHub repo）：

1. **Clone 到 /tmp** — `gh repo clone {owner}/{repo}` 到暫存區
2. **rsync `--ignore-existing`** — 遠端新檔加入本地，本地獨有保留（無覆蓋）
3. **檢查 AGENTS.md / AGENT_HANDOFF** — 接手 context
4. **本地獨有的舊版** → 移到 `_archive/`，避免跟新短檔名混淆
5. **同步 push 回 GitHub**（如果是雙向協作）

---

# 重要 memory（必讀）

- `feedback_no_version_in_client_filename.md` — 對外無版號紀律
- `feedback_auto_pdf_after_html.md` — HTML 寫完自動產 PDF
- `feedback_auto_check_page_overflow.md` — PDF QA 三件套
- `feedback_design_quality_bar.md` — 設計品質要 Pentagram 等級
- `ref_pricing_sop.md` — A/B/C 公式 + 維運 1.5–2%/月
- `feedback_case_folder_structure.md` — 4 層資料夾結構

---

# 詳細參考檔（接案開新需求書時依序讀）

| 順序 | 檔案 | 內容 |
|---|---|---|
| 1️⃣ | `ARCHITECTURE.md` | 5-Part 骨架 + 章節敘事節奏 + 頁數估算 |
| 2️⃣ | `FULL_BREAKDOWN.md` ⭐⭐ | **製造業客戶 40 頁逐頁解構**：每頁設計意圖、12 個月時間軸、Before/After 對照頁、12 個月後想像頁、交付物清單、Appendix、20 條金句、節奏密度分布 — 整本書「微觀層級」最終提煉 |
| 3️⃣ | `COMPANY_INTRO.md` ⭐ | **先判 Track A 系統案 / B 前端網頁案**，再選對應公司介紹模板 |
| 4️⃣ | `CHAPTER_TEMPLATES.md` ⭐ | 每個章節的具體寫作公式（Foreword / 規格表 / Visual / 三方案 / 加急 / 付款 / 服務承諾 / ROI / 必有 7+3 boxes） |
| 5️⃣ | `COVERS_AND_DIVIDERS.md` ⭐ | 封面 / 結尾頁 / 章節 cover 完整 HTML + 4 個 Part cover 填空 |
| 6️⃣ | `DESIGN_SYSTEM.md` | 7 色 palette + 字型 + 版面 + 元件 vocab + 9 個禁忌 |
| 7️⃣ | `CHECKLIST.md` ⭐ | 82 項完成度檢查表，送出前一一勾 |
| 8️⃣ | `PRODUCT_PITCH.md` ⭐ | **產品銷售型提案**（東西已做完但要當開案賣）：pitch vs 結案報告語氣、一條產線敘事收斂、真實 UI 截圖三件套（含 nextjs-portal 移除）、轉售定價 A 自用/B 抽成/C 買斷 + 划算點算給對方看、每月營運成本頁、Q1–Q3 收尾 |

**範本檔**：
- build 腳本 → `feature9_yidong_idp/02_需求書/_scripts/_build_official.py`
- 完整 CSS 起手樣板 → `feature9_yidong_idp/02_需求書/製造業客戶人事顧問_IDP線上化系統_提案書.html` 第 1-220 行
- Track A 完整實例 → `feature9_yidong_idp/02_需求書/_versions/v1.4_完整提案_0518.html`
- Track B 完整實例 → `feature{N}_client_project/02_提案報價/proposal_v4_需求書_demo.html`
- 產品 pitch 完整實例 → `feature14_may_viral_script/02_需求書/短影片腳本生成器_產品提案書.html`（13 頁 + assets/ 截圖）

# 沉澱來源

2026-05-18 製造業客戶 案 v1.0 → v1.4 + v1.5 提案完整實戰。
完整覆盤檔：`feature9_yidong_idp/99_其他/_SOP_提案書迭代流程.md`

2026-07-17 短影片腳本客戶生成器案 — 結案方案書改寫成開案產品提案（PRODUCT_PITCH.md 的來源）。
