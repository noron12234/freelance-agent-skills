# autonomous-polish-loop — 接案上線後雙 cron 自動 bug 監控 + UX 精修

## 為什麼要做這個 skill

接案上線後最痛的階段是「**功能都對，但細節沒人盯**」：

- Lin 忙下個案，沒空每天巡 N 個頁面看哪邊 UX 醜
- PostHog 抓到 bug 沒人即時看、新 user 又踩同個坑
- 客戶 demo 期間希望每天都能感受到「越來越精緻」
- 但是又絕對不能在客戶端推爆 prod、絕對不能讓 cron 自己決定推 prod

這個 skill 沉澱自 2026-06-20 協作徵稿平台 上線後 8 小時雙 cron 自動 polish 實戰，目標：

> **讓 Claude Code 每 30 分自動跑一個微小 polish 輪 + 每 30 分自動掃 PostHog bug，所有改動只進 test、Lin 早上起來看 email 決定推哪些 prod。**

---

## 適用情境

✅ **適合用：**
- 上線中的接案、客戶端正在使用、不能停機
- 25-50 個 UI screen / 頁面、人眼來不及一輪一輪掃
- 有 PostHog/Sentry/類似錯誤監控系統
- 有 Vercel/Render/Cloudflare Pages 類的 preview/prod 雙環境
- 有 Resend/Mailgun/Postmark 可寄 email
- Lin 願意每天早上花 5 分鐘看 email 決定推 prod

❌ **不適合用：**
- 還沒上線的 dev 階段（用 /loop 或 watch 就好）
- 沒有 sample data 可以亂玩的 prod（會誤改真實資料）
- 客戶非常敏感、任何 staging 改動都要先過 review
- 還沒有 PostHog/Sentry（bug 監控空跑）

---

## 雙 cron 架構

### Cron A: bug 監控（每 30 分）
- 查 PostHog active errors past 1h
- 簡單錯誤（hydration / null check / typo / CSS）→ 自動修 code + deploy test + email
- 複雜錯誤（DB / 商業邏輯）→ 只記錄、等人決定
- **絕不部 prod**

### Cron B: UX 嚴格優化（每 30 分）
- 從 25 features 清單抓下一個沒做過的
- 對該頁面跑 8 點 UX 檢查
- 簡單 fix → 改 code + deploy test + email
- 跑完 25 → 第二輪更深層 polish、永不停

### Cron C（autonomous loop）: 動態 pacing
- ScheduleWakeup 每 1800s 自己叫自己
- 主要當作 fallback heartbeat
- 對 Lin 來說等於有第 3 個眼睛
- **不主動 invent 工作，只 finish 還沒完成的事**

---

## State files（持久化是命脈）

### `.bot_state/feature_audit.json`
追蹤 25 features 兩個維度：
- **functional audit**（一次性）：`tested_at` + `findings` + `action`
- **UX audit**（持續）：`ui_optimized_at` + `ui_findings` + `ui_action`

格式：
```json
{
  "features": [
    {
      "id": "f01",
      "name": "公開首頁 /",
      "path": "/",
      "category": "public",
      "tested_at": "2026-06-19T21:42:48Z",
      "findings": ["..."],
      "action": "no_issue",
      "ui_optimized_at": "2026-06-20T13:00:00Z",
      "ui_findings": ["..."],
      "ui_action": "fixed"
    }
  ]
}
```

### `.bot_state/bug_tracker.json`
PostHog bug 累積記錄：
```json
{
  "last_check": "ISO",
  "last_email_sent": "ISO or null",
  "open_bugs": [
    {
      "id": "issue_id",
      "title": "...",
      "first_seen": "ISO",
      "last_seen": "ISO",
      "summary": "...",
      "fixed": false,
      "fix_commit": "describe",
      "test_url": "preview URL",
      "note": "..."
    }
  ]
}
```

寄信規則：
- A. 有新 issue → 馬上寄
- B. 距上次寄信 ≥ 3 小時且 open_bugs 非空 → reminder 寄
- C. zero bugs → 不寄

### Helper script `/tmp/ux-update.mjs`

```js
#!/usr/bin/env node
import { readFileSync, writeFileSync } from 'node:fs';
const [, , id, json] = process.argv;
const path = '/Users/linjunrong/Desktop/test/waiting-list/feature{N}_client_project/.bot_state/feature_audit.json';
const d = JSON.parse(readFileSync(path, 'utf8'));
const f = d.features.find(x => x.id === id);
const p = JSON.parse(json);
f.ui_optimized_at = new Date().toISOString();
f.ui_action = p.action;
f.ui_findings = p.findings;
writeFileSync(path, JSON.stringify(d, null, 2));
console.log(`UX ${id} → ${p.action}`);
```

用法：`node /tmp/ux-update.mjs f12 '{"action":"fixed","findings":["..."]}'`

---

## Sample data SOP（50 筆混合 status）

**絕對不要動真實資料**。塞 50 筆假 sample 跑各 status 測試：

```sql
-- email 必須 sample-N@calendar-test.local（區隔真實 user）
INSERT INTO submissions (
  author_name, author_email, title, body, status, ...
) VALUES (
  '範例投稿者 N', 'sample-N@calendar-test.local', '...', RPAD('...', 580, '。'), 'pending', ...
);
```

混合 status 比例建議：
- 30% pending
- 20% reviewing
- 15% approved (含 assigned_date)
- 15% changes_requested
- 10% awaiting_revision_review
- 5% awaiting_date_change
- 5% rejected / shipped

### 塞 sample 的踩坑

| 坑 | 解法 |
|----|------|
| `submissions_status_check` 缺 `shipped` value | `ALTER TABLE submissions DROP CONSTRAINT...ADD CONSTRAINT (status IN (...))` |
| `body` 字數 < 300 過不了 check constraint | 用 `RPAD` 補到 580–720 字 |
| tags 陣列超過 2 個被擋 | 一律 ≤ 2 tags |
| email 重複 conflict | `sample-N@calendar-test.local` N 跑流水號、別跟真實 user 撞 |
| 圖片 sample 沒上傳 | 用 placeholder URL 或 NULL |

### Cleanup（任何時刻可跑、不會誤殺真實資料）

```sql
DELETE FROM submission_images WHERE submission_id IN (
  SELECT id FROM submissions WHERE author_email LIKE 'sample-%@calendar-test.local'
);
UPDATE submissions SET deleted_at = NOW()
WHERE author_email LIKE 'sample-%@calendar-test.local';
-- 鐵則：不 hard delete、永遠可復原
```

---

## UX 嚴格檢查清單（8 點）

每輪盯一個 feature、跑這 8 點：

1. **視覺層次** — 標題大小 / 留白 / chip 對比夠嗎？盲人看得懂嗎？
2. **操作直覺** — 第一次用的人知道下一步嗎？
3. **錯誤狀態** — empty state / loading / error 都美嗎？
4. **手機 responsive** — 390×844 viewport grid 會壞嗎？
5. **a11y** — `aria-label` / `alt` / 顏色對比 ratio ≥ 4.5？
6. **微互動** — hover / focus / disabled / loading 都有反饋嗎？
7. **文字** — 錯字 / 用詞統一 / 沒內部術語（不留「v2」「DEV」「REVIEW」等）
8. **跨頁一致性** — 同類元件（chip、button、表頭）寫法統一

### 最常見的 fix（每輪 80% 就這幾個）

| Pattern | 改法 |
|---|---|
| 表格 mobile 壞 | wrap `div` 加 `overflowX:auto` + `<table>` 加 `minWidth: 640` |
| 表頭最後欄 `—` | 改「操作」+ 加 `scope="col"` |
| 卡片沒 a11y 描述 | `<Link aria-label={"含標題+投稿者+狀態的完整描述"}>` |
| 日期清單沒時間視覺 | 加「N 天前 / N 天後」chip · 3 級顏色（淡/琥珀/紅） |
| 排序沒按業務優先級 | pending 按首選日 asc、shipped 按 shipped_at desc |
| 用顏色區分但色盲看不懂 | 補 `aria-label` + 文字描述 / icon symbol |
| 6 種 hardcode 寫死 | 改 `{ITEMS.length}` 動態 |
| 雙欄 grid 手機沒 fallback | `grid-template-columns: repeat(auto-fit, minmax(280px, 1fr))` |

### 較複雜的（標 queued 不修）

- DB schema 改動
- 商業邏輯 / status 流轉
- 新 component / 新 page
- 樣式系統重構

---

## 修補分流 + deploy SOP

### 簡單（自動部 test）
```bash
# 1. 改 code（Edit tool）
# 2. tsc 檢查
npx tsc --noEmit 2>&1 | grep -E "changed/file" | head -5

# 3. 部 preview（不部 prod）
vercel deploy --yes 2>&1 | tail -3
# 取剛跑出來的 URL

# 4. 切 test alias
vercel ls 2>&1 | grep -m1 "Preview" | awk '{print $3}'
# → your-preview.vercel.app
vercel alias set your-preview.vercel.app your-project-test.vercel.app
```

### 複雜（不修、記錄）
```js
// 寫進 state action: "queued"、findings 列出改動方向、不部署
```

---

## Resend 報告 pattern

### 每輪寄信（UX cron）
```bash
curl -X POST https://api.resend.com/emails \
  -H "Authorization: Bearer re_iUG9DHTM_..." \
  -H "Content-Type: application/json" \
  -d '{
    "from": "協作徵稿平台 UX <onboarding@resend.dev>",
    "to": "noron12334@gmail.com",
    "subject": "[協作徵稿平台 UX] f12 · 需補件清單 · fixed",
    "html": "<h3>...</h3><ul>...</ul>"
  }'
```

### bug 監控寄信（規則）
- A. 有新 issue → 馬上寄、subject 含「N 個 bug 待你驗收推 prod」
- B. last_email_sent ≥ 3hr 前且 open_bugs 非空 → reminder
- 寄完更新 `last_email_sent`

### subject 標準
- UX: `[協作徵稿平台 UX] f12 · 名稱 · fixed/queued/no_issue`
- bug: `[協作徵稿平台 bot] N 個 bug 待你驗收推 prod`

---

## Vercel 操作鐵則

### 鐵則
- ❌ **絕不** `vercel deploy --prod`、推 prod 必須 Lin 親口說「推」
- ❌ **絕不** POST 任何 admin mutation API（會誤動真實資料）
- ❌ **絕不** 動 prod DB（SELECT only、sample-%@calendar-test.local 除外）
- ✅ 只動 test deploy
- ✅ 每次部 test 後手動切 alias

### Vercel CLI quirks 速查

| 問題 | 原因 / 解 |
|---|---|
| `vercel deploy --yes` 不會自動更新 alias | 部完手動 `vercel alias set <deploy> <alias>` |
| `vercel ls` 預設只顯示 production | 跑了會看到 preview 在第一行（Age 最新） |
| Vercel preview URL 401 | 拿 bypass token / 用個人帳號開 / 關保護（3 種方法）|
| Vercel preview env vars 預設 production scope | 必走 v9 PATCH API 補 `target: ["preview"]` |
| 本機 master 推不上 GitHub | 有 100MB+ wav 檔，**永遠不依賴 GitHub auto-deploy**、永遠走 `vercel deploy` |

### Production 推送（Lin 說「推」時）
```bash
# 從本機 working dir 直接部
vercel deploy --prod --yes

# 立刻手動切兩個 alias（**不會自動切**）
vercel alias set web-xxx.vercel.app your-project.vercel.app
vercel alias set web-xxx.vercel.app your-project.vercel.app
```

部 prod 前先 `git status` 確認沒有同事 WIP file 被連帶推上線。

---

## CronCreate 設定範本

Vercel Hobby 限 daily-only。協作徵稿平台案 cron 設定用 ScheduleWakeup（dynamic）+ 自定 trigger，不靠 Vercel cron。

```
# UX cron: 每 30 分（CronCreate 工具）
*/30 * * * *
trigger prompt: [協作徵稿平台 UI/UX 嚴格優化 · 每 30 分一輪] ...

# bug monitor cron: 每 30 分錯開 23 / 53 分鐘觸發
23,53 * * * *
trigger prompt: [協作徵稿平台 bug 監控 · 30 分定期] ...

# autonomous loop: dynamic 1800s heartbeat
ScheduleWakeup delaySeconds=1800 prompt=<<autonomous-loop-dynamic>>
```

---

## 18 個踩坑清單（沉澱）

| # | 坑 | 修法 |
|---|----|------|
| 1 | sample tags 3 個違反 ≤2 constraint | 全砍到 ≤2 tags |
| 2 | sample body < 300 字過不了 check | RPAD 補到 580–720 |
| 3 | submissions_status_check 缺 shipped | ALTER ADD CONSTRAINT |
| 4 | Vercel Hobby cron 限 daily | 改 `0 9 * * *` |
| 5 | tsc preferred_dates 是 string | `Number(pa.month)` 強制轉 |
| 6 | `req.json()` 對 FormData 炸 | 加 `if (ct.startsWith("multipart/form-data"))` |
| 7 | `撞期 chip` 取代原 status 害人 confused | 改成兩個並列 chip |
| 8 | 批次 approved 過濾掉沒 assigned_date | Option B：含進 queue、加 warning flag |
| 9 | 完整度警告沒列出哪篇缺日期 | 加 incompleteList + clickable link 詳情頁 |
| 10 | submit API 丟掉 authorAddress | 加 dual write to recipient_address |
| 11 | vercel deploy --prod 連帶推同事 WIP | 部 prod 前 `git status` 確認、必要 stash |
| 12 | preview env vars 預設 production scope | v9 PATCH API 補 preview target |
| 13 | project-a-2027 alias 不自動更新 | 部 prod 必手動切兩個 alias |
| 14 | 100MB wav 檔卡 master push | 永遠用 vercel deploy、別依賴 GH auto-deploy |
| 15 | RefreshButton hydration mismatch | `useState<Date \| null>(null)` + useEffect setNow |
| 16 | Lin admin testing 自己觸發 PostHog issue | note 標 monitor + 等 ≥3 occurrences 才回頭看 |
| 17 | cross-origin script error 沒 source | note 標 ignored + cross-origin noise |
| 18 | mailer redirect 模式忘了切 | MAIL_REDIRECT_TO=noron12334@gmail.com env |

---

## 完整輪流程圖（每 30 分）

```
─── UX cron 觸發 ───
1. 讀 .bot_state/feature_audit.json
2. 抓下一個 ui_optimized_at == null 的 feature
3. Read 該 page.tsx + Components
4. 跑 8 點 UX 檢查
5. 分流：
   ├─ 簡單 → Edit code → tsc check → vercel deploy --yes → alias set → state fixed
   ├─ 複雜 → state queued、不部
   └─ 無問題 → state no_issue
6. node /tmp/ux-update.mjs <id> '{...}'
7. curl Resend 寄信給 Lin
8. （Claude Code 介面 silent、全部走 email）

─── bug 監控 cron 觸發 ───
1. 讀 .bot_state/bug_tracker.json
2. mcp__posthog__exec query-error-tracking-issues-list (past 1h)
3. 對齊 state：
   ├─ 新 issue → 加 open_bugs + email 觸發
   ├─ resolved → 從 open_bugs 移除
   └─ fixed 但仍 active → 重修
4. 簡單 → 修 code + deploy test + state.fix_commit
5. 寄信決策（A/B/C 規則）
6. 寫回 state
7. （介面 silent）

─── autonomous loop tick ───
1. 看 conversation 是否有 in-progress 工作
2. 沒就 ScheduleWakeup 下一輪 1800s
3. 三輪 nothing-to-do 就 quiet 一句話
```

---

## 反思紀律

每跑完 N 輪 cron 後問自己：

1. 有沒有寄信頻率太高，吵到 Lin？→ 調 last_email_sent 條件
2. 有沒有 fix 沒生效仍 active？→ 標 fixed=false 重修
3. 有沒有 deploy 沒切 alias 害 Lin 看不到？→ 加在每次 deploy 後必跑
4. 有沒有自己 invent 新工作（不在 25 list 內）→ 立刻砍掉
5. 有沒有 push prod 沒等 Lin 親口說「推」？→ 紅旗、檢討 cron prompt

把答案 commit 進 SKILL.md。

---

## 觸發句

當 Lin 說以下任一句，就啟動本 skill：

- 「設個 cron 每 30 分跑」
- 「啟動 GoDreamer 模式」
- 「持續跑 goaldriven、不要停」
- 「嚴格上優化、UI/UX 什麼都要變得更好」
- 「30 分跑一輪、把 N 個 feature 都跑完」
- 「自動修 bug、不要動 prod」

---

## 衍生 sub-skill 機會

- `autonomous-polish-loop-init`：第一次塞 25 features + sample data + state file
- `cron-resend-reporter`：抽出寄信 helper
- `vercel-test-alias-flow`：preview deploy + alias 切換的細部 SOP

---

最後更新：2026-06-20 16:00 — 沉澱自協作徵稿平台 上線後 8 小時 16 輪雙 cron polish 實戰
