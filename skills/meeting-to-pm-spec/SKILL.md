---
name: meeting-to-pm-spec
description: 會議自動化全 pipeline。input 可以是 Google Drive 連結 / 本機檔案路徑，模式分「交接（handoff，給工程師 P0/P1/P2 清單）」與「一般（outline，會議大綱+待辦+決議）」。自動跑 rclone Drive 下載 → whisper.cpp 逐字稿 → agent 分析 → HTML+PDF → 寫進 Get 筆記。新專案自動建 case 資料夾。觸發：「整理會議」「轉成 PM 規劃書」「做成上次那種清單」「meeting to spec」「丟 Drive 連結整理」。沉澱自 線上課程客戶案 2026-06-02 SOP，2026-06-10 升 v2（雙模式 + Drive + Get筆記）。
type: workflow
---

# meeting-to-pm-spec（v2 · 2026-06-10）

> 一條指令：Drive 連結／本機影音 → 結構化會議文件（HTML + PDF）→ Get 筆記同步。

## 何時用

用戶丟一段會議錄影 / 錄音 / Drive 連結，並要求「整理」「轉成規劃書」「做成上次那種」：
- **觸發詞**：「整理會議」「轉成 PM 規劃書」「做成上次 線上課程客戶 那種表格」「meeting to spec」「整理成給工程師的清單」「會議錄音變需求書」「會議大綱」
- **接受的 input**：
  - Google Drive 資料夾／檔案連結
  - 本機 `.mp4` / `.mov` / `.m4a` / `.wav` / `.mp3`
  - 直接的 Drive folder ID

不適用於：客戶提案會議（用 `/gen-discovery-doc`、`/gen-demo-proposal` 等 5-stage 生產線）、純逐字稿（用 `/whisper`）。

## 兩種模式（agent 自動判斷）

| 模式 | 何時 | 產出 |
|---|---|---|
| **handoff（交接）** | 對工程師派工、修改清單、QA 對稿、bug 修整、定稿期 polish | P0/P1/P2 表 + 驗收矩陣 + 完整會議記錄（沿用 線上課程客戶 SOP） |
| **outline（一般）** | 客戶需求會議、內部討論、初次接觸、定位／策略討論 | TL;DR + 決議 + 待辦表 + 議題分段 + 開放問題 |

**判斷規則**（依用戶話 + 逐字稿內容判，不要問）：
- 用戶說「給工程師的」「派工」「修改清單」「對稿」「驗收」→ handoff
- 用戶說「整理」「大綱」「會議記錄」「重點」+ 逐字稿沒有明顯「修改項」「驗收標準」→ outline
- 拿不準就 outline（資訊損失較小）

## 輸入

必要（擇一）：
- `<drive_url>` — Google Drive 資料夾或檔案連結
- `<video_or_audio_path>` — 本機影音檔絕對路徑

選用：
- `<case_folder>` — 已存在案件根目錄（例：`feature{N}_client_project/`）。**新專案**就讓 agent 從會議主題自動建一個 `feature{N}_{slug}/`
- `<topic>` — 會議主題，自動從檔名或逐字稿推
- `<meeting_date>` — 日期，自動從檔案 mtime 或檔名推
- `<mode>` — 強制 `handoff` 或 `outline`

## Pipeline（v2 · 8 步）

### Step 0：拿到本機檔案

**若 input 是 Drive 連結／folder ID**：
```bash
~/.claude/skills/meeting-to-pm-spec/bin/drive_download.sh "<drive_url_or_id>" <out_dir> [pattern]
```
- `pattern` 是檔名 glob（例：`May*Recording*`），不給就抓資料夾內全部
- 若 rclone remote `gdrive` 不存在，腳本會提示用一次性指令建立：
  `rclone config create gdrive drive scope=drive config_is_local=true`（會打開瀏覽器 OAuth，3 秒搞定）
- 一次認證後永久有效，未來所有 Drive folder（含 Meet 自動錄影目錄）都能直接拉

**若 input 已是本機路徑**：跳過 Step 0。

### Step 0.5：模式 + case folder 決定

讀檔名／檔案 mtime / 用戶語意：
- 判斷模式 `handoff` vs `outline`（見上表）
- 推會議主題（例：「需求會議」「業師討論」「對稿會議」）
- 推會議日期（檔名常帶 `2026-06-10` 或從 mtime）

**case folder 規則**：
- 用戶有提到既有 case：用該路徑
- 沒提到 → 從會議主題抓客戶名（「May × 次元創意」→ `may`）
- 看 `~/Desktop/test/waiting-list/` 有沒有 `feature*_<slug>/`，沒有就建 `feature{次最大+1}_<slug>/`
- 進去後建 `04_會議/<YYYY-MM-DD>_<topic>/{原始素材,逐字稿,交付文件}/`

### Step 1：把音檔抽出來
用 `bin/transcribe.sh` 包好 ffmpeg + whisper-cli：
```bash
~/.claude/skills/meeting-to-pm-spec/bin/transcribe.sh <input> <out_dir>
```
- 影片 → ffmpeg 抽 16kHz mono wav
- 音檔直接餵 whisper-cli `ggml-small.bin`（已裝在 `~/Documents/Codex/2026-06-03/.../models/ggml-small.bin`）
- 輸出 `meeting_transcript.txt` + `meeting_transcript.srt`

長影片（>30 分）會跑 3-8 分鐘，**在背景跑**（`run_in_background: true`），同時做其他事。

### Step 2：分析逐字稿（依模式分流）

讀 `meeting_transcript.txt`（通常 800-2000 行）。**先看模式**：

#### 模式 A · handoff（給工程師）

**抽出可工程化的修改項目**（不要把客戶閒聊、寒暄塞進去）：
- 一句「這裡字體要對齊 Figma」= 一條 item
- 一段「跨裝置 Loading 壞掉」= 一條 item，但要描述清楚哪些裝置

**指派優先級**（沿用 線上課程客戶 SOP 三層）：
- **P0** = 阻擋本輪交付、影響可用性（崩壞、首屏壞、跨裝置斷裂、字體完全錯）
- **P1** = 必修但不阻擋（視覺品質、易讀性、版型微調、輪播比例）
- **P2** = 可延後但要列（部署權限、未來素材尺寸、Footer 文字、Accordion 細節）

**每條 item 必須有：**
- `優先級` (P0/P1/P2)
- `項目名` (8-15 字)
- `修改內容` (情境描述 + 具體要改什麼，2-4 句)
- `驗收標準` (怎麼算做完，2-3 句，**桌機/手機/社群內建瀏覽器分開列**)

**驗收矩陣** — 一定要寫一張表：
- 手機一般瀏覽（Chrome / Safari）
- 社群內建瀏覽器（LINE / IG / Messenger）
- 桌機瀏覽
- 文案與素材依賴

**完整會議記錄** — 依錄音時間分段（0-5 分 / 5-15 分 / ...），每段「討論摘要」+「決議」。

**完成定義** — 寫死在開頭的 note box，講「對齊 Figma；做不到先講」。

#### 模式 B · outline（會議大綱）

抽結構化重點，不分 P0/P1/P2：

**TL;DR**（一句話 60-80 字）：本次會議是什麼會、誰跟誰、得出什麼結論。

**決議事項**（`<ol>`）：明確被拍板的事，每條一句話。
- 「客戶選 Direction A」「合約走 30/40/30」「下次會議 6/14」
- 沒拍板的「也許」「考慮」不要塞進來，放開放問題

**待辦表**（4 欄：待辦 / 負責人 / 期限 / 備註）：
- 任何「我會去查」「下週給」「先準備」都列
- 負責人若沒講就寫「Lin」或「客戶」依語境
- 期限沒講就寫「下次會議前」

**議題分段**（依主題，不是時間）：
- 預算討論 / 系統範圍 / 視覺方向 / 時程節奏 等
- 每段 2-4 句客觀摘要 + 1-2 個關鍵引述（"原話 "）

**開放問題**（`<ul>`）：未決定、需要客戶補資料、需要再開會的

**完整會議大綱**（依時序，0-5 分 / 5-15 分 / ...）：與 handoff 模式同格式，但每段重點是「聊了什麼」而非「決議什麼」。

### Step 3：填模板（依模式選）

**Handoff 模式** → `templates/handoff.html`
**Outline 模式** → `templates/outline.html`，變數：
- `{{TITLE}}` — 主標（例：「May × 次元創意 · 需求會議」）
- `{{SUBTITLE}}` — 一句 subtitle
- `{{VIDEO_SOURCE}}` — 影片檔名 + 來源
- `{{VIDEO_DURATION}}` — `mm:ss`
- `{{DOC_DATE}}` — 產文件日期
- `{{ATTENDEES}}` — 與會人（從逐字稿推）
- `{{TLDR}}` — 一段 TL;DR
- `{{DECISIONS_LIST}}` — `<li>` 決議列表
- `{{ACTION_ITEMS_TABLE}}` — 待辦 `<tbody>`
- `{{TOPICS_SECTION}}` — 議題分段 `<h3>` + `<p>`
- `{{OPEN_QUESTIONS_LIST}}` — `<li>` 開放問題
- `{{MEETING_TIMELINE}}` — 完整時序 `<h3>` + `<p>`

---

**Handoff 模式變數**（沿用原本，沒變）：
- `{{TITLE}}` — 文件主標
- `{{SUBTITLE}}` — 一句話 subtitle
- `{{VIDEO_SOURCE}}` — 影片檔名 + 時間
- `{{VIDEO_DURATION}}` — `mm:ss` 或 `hh:mm:ss`
- `{{DOC_DATE}}` — 產文件日期
- `{{MAIN_CONCLUSION}}` — 一句話本輪交付重點
- `{{COMPLETION_DEFINITION}}` — note box 內文
- `{{DEADLINE_LIST}}` — `<ul>` 死線列表
- `{{ENGINEERING_ITEMS_TABLE}}` — 工程修改清單 `<tbody>` 全部 `<tr>`
- `{{ACCEPTANCE_MATRIX_TABLE}}` — 驗收矩陣 `<tbody>`
- `{{MEETING_NOTES}}` — 完整會議記錄的所有 `<h3>` + `<p>`
- `{{FOLLOWUP_LIST}}` — 後續追蹤建議 `<ol>`

不要重發明 CSS、不要改字體大小、不要加 emoji。模板已經穩定。

### Step 4：渲染 PDF
```bash
~/.claude/skills/meeting-to-pm-spec/bin/render_pdf.py <html_path> <pdf_path>
```
Playwright headless Chromium 印 A4。約 3 秒。

### Step 5：寫 LINE 轉發版（**僅 handoff 模式**）
> Outline 模式跳過 Step 5（會議大綱本來就短，PDF 本身就可轉發）。

從 step 2 的結構化資料產輕量「轉發版」，**兩個檔同時產**：

1. **`工程師修改清單_LINE版.md`** — 純 markdown 表格，直接貼 LINE / Slack / 訊息給工程師。
2. **`工程師修改清單_LINE版.html` → `.pdf`** — 用同一份 `templates/handoff.html` 模板，但內容砍掉「完整會議記錄」段落，只保留：
   - 封面（eyebrow 改 `Engineer Quick Reference`、subtitle 寫「精簡轉發版」）
   - 一、PM 總要求
   - 二、工程修改清單
   - 三、驗收矩陣
   - 四、時程節點
   - 備註：指向完整版 PDF
   
   渲染完直接呼叫 `bin/render_pdf.py`。

**為什麼要兩個**：完整版 PDF 通常 1.5MB+ 不適合直接訊息傳；LINE 版 PDF 約 1MB 但只有 4 頁，工程師掃一眼就知道做什麼，比 markdown 更正式、可附件、可截圖局部。Markdown 給「先用文字溝通」場景，PDF 給「正式派工存檔」場景。

### Step 6：QA PDF 排版
兩份 PDF 都跑：
```bash
pdfinfo <pdf> | grep -E "Pages|Page size"
for p in $(seq 1 N); do pdftotext -f $p -l $p <pdf> -; done
```
檢查：
- 沒有頁面 chars < 100（可能是孤兒頁）
- 沒有頁面 chars > 3500（A4 9.7pt 表格極限，超過就溢位）
- 最後一頁不要只有 1-2 行（孤兒尾頁，調整模板上方間距）

排版規則沿用 `feedback_auto_check_page_overflow.md`。

### Step 7：寫進 Get 筆記（**最後一步**）

PDF 完成後，把摘要寫進 Get 筆記：

1. **挑選或建立 topic**：
   - `mcp__getnote__list_topics` 看現有
   - 找 `客戶會議記錄`／`接案會議`／案件專屬 topic，沒有就 `mcp__getnote__create_topic` 建一個（建議：`客戶會議記錄`）

2. **發筆記**：`mcp__getnote__save_note`
   - `note_type=plain_text`
   - `title` = `[YYYY-MM-DD] <客戶/案件> · <會議主題>`
   - `content` = markdown 摘要：
     - **handoff 模式**：總要求 + 工程清單表（簡化版）+ 死線 + 連結至完整 PDF 本機路徑
     - **outline 模式**：TL;DR + 決議 + 待辦表 + 開放問題 + 連結至完整 PDF 本機路徑
   - `tags` = `["會議", "<案件 slug>", "<mode>"]`（最多 5 個）
   - **不要塞完整時序逐字稿** — Get 筆記是「之後翻得到」的層次，細節在 PDF

3. 用 `parent_id` 把這篇歸到上一篇同案件的「索引筆記」下（如果有）。

4. 告知用戶 Get 筆記內鏈：`https://biji.com/note/<note_id>`

## 標準輸出資料夾

**Handoff 模式**：
```
<case_folder>/04_會議/<YYYY-MM-DD>_<topic>/
├── 原始素材/
│   └── <原檔名>.mp4
├── 逐字稿/
│   ├── meeting_transcript.txt
│   └── meeting_transcript.srt
└── 交付文件/
    ├── <topic>_PM給工程師修改清單與會議記錄.html
    ├── <topic>_PM給工程師修改清單與會議記錄.pdf
    ├── 工程師修改清單_LINE版.md
    ├── 工程師修改清單_LINE版.html
    └── 工程師修改清單_LINE版.pdf
```

**Outline 模式**：
```
<case_folder>/04_會議/<YYYY-MM-DD>_<topic>/
├── 原始素材/
│   └── <原檔名>.mp4
├── 逐字稿/
│   ├── meeting_transcript.txt
│   └── meeting_transcript.srt
└── 交付文件/
    ├── <topic>_會議大綱.html
    └── <topic>_會議大綱.pdf
```

檔名 **不要帶版號**（vX.X），這是對外/對工程師的檔案 — 沿用 `feedback_no_version_in_client_filename.md` 規則。

## Linear 寫入（選用）

問用戶要不要同步寫進 Linear。若要：
- 全部 item 塞 **一個 issue**（沿用 線上課程客戶 SOP，**不要拆 sub-issue**）
- 掛新 milestone（例：「階段 X.5｜補救」）或現有 milestone
- 工作流：實作者 → QA → Lin → 對外，每個節點提早 2 天

預設不寫，要寫的話再問一次「要不要 push 到 Linear？」。

## 死線安排（建議模板）

從本日推算：
- **PM 整理清單** = 會議當日 + 24 小時
- **工程師完成** = 整理完成 + 2 天
- **內部 QA** = 工程完成當天 24:00
- **對外** = QA 後隔日 24:00

## 邊界 / 不做的事

- ❌ 不要嘗試自動寄信給工程師（用 `case-sync` 之外的訊息系統）
- ❌ 不要自動部署任何東西
- ❌ 不要寫客戶版本（沿用 `feedback_no_client_readonly_view`）
- ❌ 不要在 PDF 裡塞 emoji / 客戶 logo / 設計圖（純黑白資訊密集排版）
- ❌ 不要重 transcribe 已存在的逐字稿（同資料夾有 `meeting_transcript.txt` 就跳過 Step 1）

## 故障排除

| 症狀 | 處理 |
|---|---|
| `whisper-cli: command not found` | `brew install whisper-cpp` |
| 找不到 model | 預期路徑 `~/Documents/Codex/2026-06-03/.../models/ggml-small.bin`，缺的話：`curl -L -o ~/.cache/whisper/ggml-small.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin` 後改 `transcribe.sh` 內 `MODEL` 變數 |
| 逐字稿全是英文猜測 | whisper-cli 自動判語言失敗，加 `-l zh` 參數 |
| PDF 字體錯亂（變成豆腐字） | 確認 Mac 內建 PingFang TC 在；若無，在 `templates/handoff.html` 改 font-family 為 `Noto Sans TC` 並裝 `brew install --cask font-noto-sans-cjk-tc` |
| Playwright 沒裝 | `python3 -m pip install playwright && python3 -m playwright install chromium` |

## 用過的黃金 reference

### Handoff 模式 — 線上課程客戶案 2026-06-02 業師討論（54:58 影片）
- `feature{N}_client_project/04_會議/2026-06-02_網站業師討論/`
- 13 項：P0×3 / P1×6 / P2×4
- 寫進 Linear OUT-26 單一 issue + milestone「階段 4.5｜定稿期補救」

### Outline 模式 — 短影片腳本客戶生成器案 2026-06-10 需求會議（51:53 影片）
- 來源：Drive 連結 → rclone 拉 → whisper 6 chunk → outline HTML/PDF（8 頁 A4）→ Get 筆記
- `feature14_may_viral_script/04_會議/2026-06-10_需求會議/`
- 客戶 May 委託開發「短影片爆款腳本生成器」AI 工具
- Get 筆記內鏈：https://biji.com/note/1912436493591380584（topic「接案會議記錄」`Job6K7y0`）

若需要對照「上次長怎樣」就讀那份 HTML。
