# PostHog 自訂事件 Cheatsheet（按網站類型抄）

> 直接 `import posthog from 'posthog-js'` 然後 `posthog.capture('event_name', { properties })` 即可。
> property 命名一律 snake_case、value 用最簡單的型別（string / number / boolean）。

---

## 🅰️ 投稿 / 問卷 / 報名 類

**範本案例**：協作徵稿平台、活動報名、徵稿、申請表單

```ts
// 用戶開始互動（聚焦第一個欄位、進入「投稿模式」）
posthog.capture("form_started", { form_id: "submit" });

// 用戶選了照片但取消（猶豫指標）
posthog.capture("photo_upload_cancelled");

// 用戶選了照片
posthog.capture("photo_upload_attempted", { count: files.length });

// 前端 reject 照片（細分原因）
posthog.capture("photo_upload_rejected", {
  reason: "too_large" | "not_image" | "too_many",
  size_mb: (f.size / 1024 / 1024).toFixed(1),
  mime: f.type,
});

// 按了送出（前端 validation 過）
posthog.capture("submission_attempted", {
  word_count: body.length,
  image_count: images.length,
  has_phone: !!phone.trim(),
  // 任何「分組」的維度都進來
});

// API 200 OK
posthog.capture("submission_succeeded", { submission_id: json.id });

// API 非 200 或 network error
posthog.capture("submission_failed", {
  status: res.status,
  error: json.error ?? "network",
});
```

**對應 funnel**：`$pageview /submit → photo_upload_attempted → submission_attempted → submission_succeeded`

---

## 🅱️ 電商 / 結帳 類

**範本案例**：商城、品牌獨立站、訂閱

```ts
posthog.capture("product_viewed", { product_id, price, category });
posthog.capture("add_to_cart", { product_id, qty, price });
posthog.capture("cart_viewed", { items_count, total });
posthog.capture("checkout_started", { payment_method: "credit_card" });
posthog.capture("checkout_failed", { reason: "card_declined" });
posthog.capture("purchase_completed", { order_id, total, items_count });
```

**對應 funnel**：`product_viewed → add_to_cart → checkout_started → purchase_completed`

---

## 🅲️ 內容 / 媒體 / 部落格 類

**範本案例**：作品集、blog、新聞、長文

```ts
posthog.capture("content_viewed", { slug, category, read_time_min });
posthog.capture("scroll_50", { slug });  // 滾到 50%
posthog.capture("scroll_complete", { slug });  // 滾到底
posthog.capture("share_clicked", { platform: "line" | "fb" | "copy" });
posthog.capture("cta_clicked", { cta_id: "subscribe_newsletter" });
posthog.capture("video_played", { video_id, duration });
posthog.capture("video_finished", { video_id });
```

---

## 🅳️ SaaS / 工具 / Dashboard 類

```ts
posthog.identify(userId, { email, plan, signup_date });  // 登入時
posthog.capture("feature_used", { feature: "export_csv" });
posthog.capture("upgrade_clicked", { from_plan: "free", to_plan: "pro" });
posthog.capture("subscription_started", { plan, mrr });
posthog.capture("churned", { plan, days_active });
```

---

## 命名規則（重要、之後 funnel 才好做）

| ✅ Do | ❌ Don't |
|---|---|
| `submission_succeeded` | `submitSucceeded` / `SubmissionDone` |
| `photo_upload_rejected` | `error` / `oops` |
| snake_case 動詞 + 過去式 | 用 ing 結尾、camelCase、CapitalCase |
| property: `reason: "too_large"` | `errorType: "too_large"` |

**Why**：PostHog dashboard / SQL / breakdown 都依名稱、命名混亂後想做 funnel 找不到。

---

## 不要做的事

- ❌ 不要 capture 大量 noise event（每次 scroll、每次 keystroke）→ 5,000 session/月 free tier 容易爆
- ❌ 不要在 capture 內放 PII（email / phone / 真實姓名）→ 違反 PostHog 自家 ToS + GDPR
- ❌ 不要在 SSR 跑 `posthog.capture`（PostHog SDK 是 client-only）

## 要做的事

- ✅ 一個流程的「**漏斗 4 步**」必抓（開頁 / 開始操作 / 提交 / 成功）
- ✅ 失敗類 event 必帶 `reason` property（後續 breakdown）
- ✅ 上線前用 `posthog.opt_out_capturing()` 確認本機不污染 prod 數據（dev 模式 SDK 已 noop）
