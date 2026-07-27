---
name: integrate-posthog-tracking
description: Next.js 接案網站一條龍裝好 PostHog（session replay + funnel + error tracking + MCP），5 分鐘 ready
---

# integrate-posthog-tracking

> 給接案網站裝 PostHog 的完整 SOP。沉澱自協作徵稿平台 案 2026-06-16 實作、跨案可直接抄。

## 何時用

客戶或自己想要：
- 看真實使用者在站上怎麼操作（卡哪步、按了哪、為什麼跳）
- bug 報告時不用客戶截圖、自己 dashboard 就能查
- 看每天 / 每週多少人轉換成「目標動作」（投稿 / 購買 / 註冊）
- 比 Google Analytics 視覺、比 Hotjar 不收費、比 Microsoft Clarity 多 funnel

不適用：純靜態網站（沒有任何使用者互動目標）

## 為什麼選 PostHog vs 別人

| 工具 | 為什麼 / 為什麼不 |
|---|---|
| **PostHog**（這 skill 用）| 5K session/月免費、含 session replay + funnel + error tracking + MCP、開發者導向 |
| Microsoft Clarity | 完全免費無上限、但介面行銷導向、**沒 funnel** |
| Hotjar | 35 session/天 free、無 funnel |
| Google Analytics 4 | 流量大時免費、但**沒 session replay**、學習曲線陡 |

決策樹：
- 客戶只要「看訪客在幹嘛」→ Clarity 簡單
- 客戶 / 自己要看「漏斗轉換 + bug 追蹤」→ **PostHog 這 skill**
- 純流量統計 → GA4

## 6 步 Pipeline

### Step 1 · 裝 SDK
```bash
cd <project>/web
npm install posthog-js
```

### Step 2 · 寫 PostHogProvider
複製 `templates/PostHogProvider.tsx` 到 `src/components/analytics/PostHogProvider.tsx`、不必改。

### Step 3 · 包進 layout.tsx
```tsx
import { Suspense } from "react";
import { PostHogProvider } from "@/components/analytics/PostHogProvider";

<body>
  <Suspense fallback={null}>
    <PostHogProvider>{children}</PostHogProvider>
  </Suspense>
</body>
```

**必須用 Suspense 包**，否則 `useSearchParams` 在 build 時報錯。

### Step 4 · 加 6-8 個自訂事件
看 `templates/custom-events-cheatsheet.md`、按該站類型挑模式：
- **投稿 / 問卷** 類：`form_started` / `field_focused` / `validation_failed` / `submission_attempted` / `submission_succeeded` / `submission_failed`
- **電商** 類：`product_viewed` / `add_to_cart` / `checkout_started` / `payment_failed` / `purchase_completed`
- **內容** 類：`content_viewed` / `scroll_50` / `scroll_complete` / `share_clicked` / `cta_clicked`

每個關鍵動作 fire `posthog.capture('event_name', { property_1, property_2 })`。

### Step 5 · 設 env vars + deploy
1. 用戶到 https://posthog.com/signup 註冊（不要信用卡、選 US 或 EU region）
2. 拿 **Project API Key**（`phc_` 開頭、在 onboarding 或 Project settings）
3. 設 Vercel env vars：
   ```bash
   vercel env add NEXT_PUBLIC_POSTHOG_KEY production    # 填 phc_...
   vercel env add NEXT_PUBLIC_POSTHOG_HOST production   # https://us.i.posthog.com 或 eu
   vercel deploy --prod                                  # NEXT_PUBLIC_* 必須 redeploy
   ```
4. 用 playwright 開頁、看 network → 應有 POST 到 `us.i.posthog.com` 200

### Step 6 · API bootstrap（啟 toggle + 建 funnel + dashboard）
跑 `bootstrap/api-setup.sh`、輸入 Personal API Key（`phx_` 開頭、Settings → Personal API Keys → All scopes）+ Project ID（從 URL `posthog.com/project/471715/...` 看）。

腳本會自動：
- 啟用 6 個 toggle（session_recording / heatmaps / autocapture / exceptions / performance / console_log）
- 改 project 名字
- 建投稿漏斗 funnel
- 建每日成功趨勢 trend
- 建被拒原因細分
- 建 dashboard 收 3 個 insight

## Step 7（選）· 配 PostHog MCP for Claude Code

讓 AI 直接 query PostHog 數據、不用客戶截圖：

```bash
# 編輯 ~/.claude.json 加：
{
  "mcpServers": {
    "posthog": {
      "type": "http",
      "url": "https://mcp.posthog.com/mcp",
      "headers": { "Authorization": "Bearer phx_..." }
    }
  }
}
```

用 python 自動加（避免手動編 JSON 出錯）：
```bash
python3 -c "
import json
with open('$HOME/.claude.json') as f: d = json.load(f)
d.setdefault('mcpServers', {})['posthog'] = {
    'type': 'http',
    'url': 'https://mcp.posthog.com/mcp',
    'headers': {'Authorization': 'Bearer phx_YOUR_PERSONAL_KEY'}
}
with open('$HOME/.claude.json', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
"
```

加完**必須重啟 Claude Code** 才會載新 MCP server。

## 隱私 / 法規

- SDK 預設 `maskAllInputs: true` → input/textarea 內容自動 mask 成 `●●●`、看不到 PII
- 對特定元素加 `data-mask` 屬性會額外 mask
- 拍 session recording 屬於行為資料、**接案合約須註明**：「為改善服務、本站使用第三方分析工具（PostHog）記錄使用行為，不含個資。」
- GDPR / 個資法：PostHog EU region 自動符合、US region 客戶要明示

## 常見坑

| 症狀 | 解 |
|---|---|
| Build 報 `useSearchParams must be wrapped in Suspense` | layout.tsx 用 `<Suspense fallback={null}>` 包 PostHogProvider |
| env 設了還是沒收到 event | `NEXT_PUBLIC_*` 是 **build-time inline**、改 env 必須 redeploy 才生效 |
| Activity 頁有 events、但 Session replay 列表空 | PostHog **預設 project 層的 session_recording_opt_in 是 OFF**、要 dashboard Settings 手動開、或用 API bootstrap 開 |
| MCP 加了但 Claude Code 看不到 | 必須**完全退出 + 重開**、不是 `:reload`、是整個 process 結束 |
| iOS Safari `window.posthog` undefined | SDK 是 module-level、不掛 window、用 `import posthog from 'posthog-js'` 引入即可 |
| 收到 Personal API key 是 `phx_` 開頭、別跟 `phc_`（Project API key）混 | `phc_` 給前端 SDK；`phx_` 給後端 API call + MCP |

## 對外文件結構

接案做完這個 skill 後、產交付物：
- 客戶版 dashboard URL（PostHog dashboard 公開分享連結）
- 簡易使用說明（教客戶看 funnel + replay）— 寫進該案 `00_客戶端/使用說明書/` 內

## Reference 實作

第一次跑：協作徵稿平台（feature{N}_client_project/web）、2026-06-16 02:00
- Dashboard: https://us.posthog.com/project/471715/dashboard/1716071
- 6 個自訂事件: photo_upload_attempted / photo_upload_cancelled / photo_upload_rejected / submission_attempted / submission_succeeded / submission_failed
- 用時：從 0 到 ready 約 30 分鐘（含解 Suspense bug、解 session_recording_opt_in 預設關）

下次接案可直接抄 `templates/PostHogProvider.tsx` + 跑 `bootstrap/api-setup.sh`、應該能壓在 10 分鐘內。
