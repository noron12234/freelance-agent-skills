---
name: copy-competitor-workspace
description: 用戶要照抄競品 UI/UX 的完整方法論 — 用 browser MCP 實測登入後的 workspace（landing 資訊不夠）、拆四維度（sidebar/主 grid/detail 頁/成本透明化）、對照自產品列可抄清單按投報比、每手法獨立 commit 保留 revert 點、對外白話化拿掉技術詞。沉澱自 2026-07-18 抄 Sandcastles 到 短影片腳本客戶產品實戰。
---

# 照抄競品 workspace 方法論

## 觸發時機

- 「照抄 XX」「XX 有什麼可以模仿的」「這個產品可以怎麼優化」
- 用戶指名一個競品要對比
- 產品 owner 說「這個 landing 挺不錯」代表方向認可、繼續照這個風格加碼

## 核心原則

**Landing page 不是實測 workspace**。用戶問「有沒有可以照抄的」時，只讀 landing 只能拿到「行銷金句 + 產品定位」；真正可抄的 UX 全在登入後的 workspace 內部。**必用 browser MCP 實際點進去看**。

## 標準流程

### Step 1 · Browser MCP 實測（不是 WebFetch）

```
1. tabs_context_mcp createIfEmpty:true → 拿到 tabId
2. navigate → 競品官網
3. screenshot → landing hero + 產品定位
4. scroll + screenshot × N → 抓 landing 的 mockup（他們自己 showcase 的 workspace 樣式）
5. find "Login button" or 直接導 app subdomain（如 app.sandcastles.ai）
6. 用戶有登入 → 直接進 workspace 抓 sidebar / 主頁 / detail 頁
7. 用戶沒登入 → 至少要能截到 landing 的 workspace mockup
```

**用 browser_batch** 一次做 navigate + wait + screenshot × N，比單獨 call 快很多。

### Step 2 · 拆四維度（每維度都要拆）

競品內部 UX 拆成四類、每類都拿出來對比：

1. **Sidebar 結構** — 導覽分幾組？每組幾個功能？active state 樣式？底部有沒有 CTA badge？
2. **主 grid / 列表頁** — filter 側欄有多少項？每張卡片顯示什麼資料？hover 才顯示還是永遠顯示？
3. **Detail / 單支頁** — 有沒有分 tab？tab bar 樣式？右上 CTA 有沒有？進度條/breadcrumb？
4. **成本 / 透明化** — 有沒有寫每次操作花多少？免費額度剩多少？定價層級？

### Step 3 · 對照自產品現況、列可抄清單

**每個維度都列 2-3 個可抄手法**，最終 8-15 個。每個手法標：
- **投報比**（⭐⭐⭐⭐ 最高 vs ⭐ 最低）
- **成本估算**（分鐘/小時）
- **風險等級**（refactor 大小、有沒有 introduce regression）
- **具體 code 位置**（改哪個檔案哪一段）

### Step 4 · AskUserQuestion 讓用戶挑波次

不要一次全做（context 會爆、debug 麻煩）。分批：

```
Q: 這一波執行範圍？
- 這波全做（1+2+A+B+C+F+G+H）~2h
- 只做最便宜的 5 個 ~1h
- 進入最大 refactor（Studio 分 tab）~3h
- 挑其他
```

### Step 5 · 每 1-2 手法獨立 commit（保留 revert 點）

**鐵則**：用戶會說「保留 git 版本紀錄讓我可以復原」→ 每個獨立功能 commit 一次，訊息裡明列做了什麼、對應手法編號。

```bash
git add <files> && git commit -m "feat(featureN): 手法 X · 做了什麼

- bullet 1
- bullet 2

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

不要 rebase / squash，每個 commit = 一個可 revert 點。

### Step 6 · 對外 landing 白話化（技術詞禁區）

如果做完 UI overhaul 順便做 landing page：**拿掉所有技術詞**。用戶會反饋「使用者不知道這是什麼」。

| 禁止用詞 | 白話替換 |
|---|---|
| Apify / Playwright / Puppeteer | 找片系統 / 撈片、素材來源 |
| Gemini / GPT / Claude / LLM | AI |
| hashtag | 話題標籤 |
| token / compute unit / sync run | 算力 / 每次執行 |
| Google Search grounding | 上網研究 |
| Powered by X + Y | 拿掉、只留 Built by 自己 |
| $0.30 / M tokens | 拿掉、改成「保守估算上限、進系統會即時顯示」 |

Footer 只留品牌名，不寫 tech stack。

### Step 7 · Session 結尾 · 存 memory + 提煉 skill

- 新開 `project_XX_YYYY_MM_DD.md` 記本輪 UI overhaul 完整狀態
- 列所有 commit sha + 對應手法（未 push 或 push 都要註明）
- 記「進行中未完成」的部分（下 session 接手要做什麼）
- 用戶認可的方向（如「landing 挺不錯的」= 繼續 sandcastles 風）記進 memory 避免下次走回頭路

## 常見手法清單（Sandcastles 抄到的、下次可再抄）

**Sidebar 系**：
- 分三組（Research / Create / Setup）+ badge 顯示待處理數
- 底部 CTA badge（Starter plan / Upgrade）
- Active item 藍色底 + 藍框強調

**主 grid 系**：
- 三色數據 chip（依數值分級色 — 綠高橘中灰低）
- hover 才顯示 action 按鈕（保留/刪除/分析），卡片乾淨
- 影片縮圖佔滿 aspect 9:16
- Filter 側欄有 Save filter 功能

**Detail 頁系**：
- 分 tab（Topic / Research / Hook / Script）+ 右上 Continue button
- 每 tab 有 icon + label + done 勾勾
- Continue button 依當前 tab 狀態換 label/action

**拆解報告系**：
- 拆成章節（一句話重點 / 鉤子 / 結構節奏 / 為什麼爆 / 可複製公式）
- 鉤子用藍框強調、公式用藍底白字強調
- Right drawer 取代 inline expand

**成本透明化系**：
- `src/lib/costs.ts` 集中定義成本常數 + `formatCost()` helper
- 主輸入區、每個動作按鈕、billing 頁三處都露成本
- 三格 stats（跑一輪多少 / 免費幾輪 / 換一批多少）
- 「保守 upper-bound、實際帳單通常低於這數字」讓用戶放心

**Landing 系**：
- 深藍/黑底 hero + 藍色 gradient headline
- 5 站產線並排卡片（每站配色 + mock + 敘事）
- 對比金句「同一件事、10 倍效率」
- 底部單一 CTA、footer 只留品牌

## 反面案例（不要做的）

- **不要只讀 landing 就開始列可抄手法** — landing 沒有 workspace 細節
- **不要一次 refactor 全部** — Studio 分 tab 這種大改要獨立一波、其他 8-10 個手法先做完部署後再做
- **不要 landing 出現「Apify」「Gemini」** — 用戶朋友看不懂
- **不要一顆 commit 包全部** — revert 一個功能會被迫 revert 全部
- **不要跳過「用戶認可 → 繼續加碼」的訊號** — 用戶說「挺不錯的」= 這風可以繼續、下 session 別問要不要走這風

## 沉澱來源

2026-07-18 短影片腳本客戶產品抄 Sandcastles：
- 一輪內做完 8 個手法（1+2+A+B+C+F+G+H）+ 3 個追加（費用透明化 + 爆款配方庫 + /pitch landing）
- 全部 commit + 部 prod、每個手法獨立 sha 可 revert
- 用戶認可 landing → 直接進 Studio 分 4-tab 大 refactor（未完成）
- 完整覆盤在 `memory/project_may_viral_script_2026_07_18.md`
