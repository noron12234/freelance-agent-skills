---
name: case-sync
description: 自動把對話中的案件進度更新寫到案件儀表板 (feature8_project_dashboard / Insforge prod)。當用戶在 Claude Code 提到任何接案進度（合約簽了、訂金到帳、開會結果、phase 推進、新客戶、結案、暫停、Stage 上線、指派工程師、改交付項等）就觸發。Show diff → 用戶確認 → PATCH/POST 寫入。用戶主訴：「我不要當 PM，跟你聊完就自動更新就好」。支援 5 種 entity：cases / case_payments / engineers / deliverables / users。
---

# 主動觸發訊號

**不要等用戶說 `/case-sync`。** 對話出現以下訊號就跑：

## 案件層級
| 訊號 | 動作 |
|---|---|
| 「我剛接到 / 新客戶 / 又一個案」 | POST 新 case |
| 「合約簽好 / 簽回」 | phase 升到 3-4、notes append |
| 「結案 / 完工」 | phase=5 + status=done |
| 「不接了 / 暫停 / 失聯」 | status=paused/archived |
| 「客戶決定方向 X」 | notes append + 視情況推 phase |

## 付款層級 (新 schema — case_payments 表)
| 訊號 | 動作 |
|---|---|
| 「訂金到了 / 第一期入帳」 | case_payments.stage=1 → client_paid=true |
| 「公司把訂金匯給我了」 | case_payments.stage=1 → lin_paid=true |
| 「二期 / Stage 2 收了」 | stage=2 → client_paid=true |
| 「尾款 / 第三期入帳」 | stage=3 → client_paid=true |
| 「給合作窗口分潤匯了」 | partner_paid=true |
| 「付阿丁工程費了」 | engineer_paid=true |

## 交付層級 (deliverables 表)
| 訊號 | 動作 |
|---|---|
| 「Stage X 要做 [A B C]」 | INSERT deliverables 多筆 |
| 「Stage X 交付了 / 完成」 | mark all Stage X deliverables completed=true |
| 「[項目] 做完了」 | mark 單筆 completed |
| 「[項目] 改 deadline 到 X」 | update due_date |
| 「補給 [工程師] 提示：⋯」 | update handoff_notes |

## 指派層級
| 訊號 | 動作 |
|---|---|
| 「[案] 派給阿丁 / David」 | cases.primary_engineer_id = ading/david id |
| 「[案] 改派給 X」 | 同上、更換 |

## ⛔ 不要觸發
- 純查詢「線上課程客戶 現在到哪？」→ 跑 GET 給用戶看、不要寫
- 純技術討論「線上課程客戶 用什麼字型」→ 跟進度無關
- 情緒抒發「線上課程客戶 客戶好難搞」→ 沒實質變更

---

# 配置（hard-coded、改網址這裡改）

```
PROD_URL  = https://YOUR_PROJECT.insforge.site
DEV_URL   = http://localhost:3008
ENV_FILE  = /Users/linjunrong/Desktop/test/waiting-list/feature8_project_dashboard/.env.local
```

**拿 token：**
```bash
TOKEN=$(grep "^API_TOKEN=" /Users/linjunrong/Desktop/test/waiting-list/feature8_project_dashboard/.env.local | cut -d= -f2)
```

所有 API 呼叫帶 `X-API-Token: $TOKEN`。

---

# 標準 Workflow

## 步驟 1：撈現況（每次都做）

```bash
# 案件清單
curl -s -H "X-API-Token: $TOKEN" $URL/api/cases

# 案件詳情 + payments (若需 payment 操作)
curl -s -H "X-API-Token: $TOKEN" $URL/api/cases/$CASE_ID
curl -s -H "X-API-Token: $TOKEN" $URL/api/cases/$CASE_ID/payments
```

## 步驟 2：模糊 match 用戶說的案

- 「線上課程客戶 / 小羊」 → `線上課程客戶 官網`
- 「協作徵稿平台 / 會飛的手日曆」 → `協作徵稿平台 徵稿網站`
- 「Ruby / 小說」 → `小說作家有聲書官網`
- 不確定 → 列候選請用戶選、**不要猜**

## 步驟 3：show diff，等確認

```
📝 線上課程客戶 官網 (小羊老師)

  Phase 3 → 4 (開發中)
  payments Stage 1 客戶→公司: ☐ → ✓
  notes + [2026-05-17] 訂金 9K 已入帳
  
  寫進去？(y / 改 / 不用)
```

## 步驟 4：用戶說 y / 對 / 寫吧 → 跑 PATCH

```bash
# 案件本身
curl -s -X PATCH $URL/api/cases/$CASE_ID \
  -H "X-API-Token: $TOKEN" -H "Content-Type: application/json" \
  -d '{"phase": 4, "notes": "..."}'

# 付款 toggle
curl -s -X PATCH $URL/api/payments/$PAYMENT_ID \
  -H "X-API-Token: $TOKEN" -H "Content-Type: application/json" \
  -d '{"client_paid": true}'   # 後端自動填 client_paid_date=今天

# Deliverable mark done
# (需要透過 /api/cases/$CASE_ID API 拿到 deliverables，再 PATCH 該 deliverable)
```

---

# 詳細場景

## 場景 A — 新案啟動（最常見、最複雜）

用戶說「我剛接到簡單 JAN DAN 那案、案值 8 萬、自接、客戶 Sylvia」

1. **POST 新 case**
   ```bash
   curl -s -X POST $URL/api/cases \
     -H "X-API-Token: $TOKEN" -H "Content-Type: application/json" \
     -d '{
       "name": "簡單 JAN DAN SEO 修正",
       "client_name": "Sylvia",
       "phase": 1, "status": "active",
       "source": "self",
       "my_split": 100, "partner_split": 0,
       "total_value": 80000,
       "payment_pattern": "30/40/30",
       "notes": "[YYYY-MM-DD] 初次接洽"
     }'
   ```
   拿到 `case.id`。

2. **自動產 3 期付款**
   ```bash
   curl -s -X POST $URL/api/cases/$CASE_ID/payments \
     -H "X-API-Token: $TOKEN"
   ```
   後端會用 case.total_value × payment_pattern 算 24K / 32K / 24K。

3. **提議指派工程師**（如果用戶提到誰做）
   ```bash
   # 拿 engineer list
   curl -s -H "X-API-Token: $TOKEN" $URL/api/engineers  # 註：目前還沒這 API、自己 query db
   # 指派
   curl -s -X PATCH $URL/api/cases/$CASE_ID \
     -H "X-API-Token: $TOKEN" -H "Content-Type: application/json" \
     -d '{"primary_engineer_id": "<engineer_id>"}'
   ```

4. **報告連結**
   「✓ 已建『簡單 JAN DAN SEO 修正』、自動拆 3 期 24K/32K/24K，看詳情：$URL/case/$CASE_ID」

## 場景 B — 付款入帳

用戶說「線上課程客戶 訂金 9 千匯進來了、我也收到了」

1. 撈 線上課程客戶 case → 撈 線上課程客戶 的 case_payments → 找 stage=1 那筆
2. 一次 PATCH 兩個欄位（一筆 payments、兩個 axis）：
   ```bash
   curl -s -X PATCH $URL/api/payments/$PAYMENT_ID \
     -H "X-API-Token: $TOKEN" -H "Content-Type: application/json" \
     -d '{"client_paid": true, "lin_paid": true}'
   ```
3. notes append: `[YYYY-MM-DD] 訂金 9K 客戶已付 + 公司已轉帳給林`

## 場景 C — Stage 交付

用戶說「協作徵稿平台 Stage 1 上線了、客戶 confirm 通過驗收」

1. 撈 協作徵稿平台 case → 撈 deliverables (stage=1)
2. 全部 mark completed (現在沒 bulk API、可以一筆一筆跑 PATCH /api/cases/[id] 然後另外 PATCH deliverable — 但 deliverable PATCH 目前只有 /api/engineer/deliverables/[id] 給工程師用、admin 沒有專屬 API)
3. notes append: `[YYYY-MM-DD] Stage 1 客戶驗收通過`
4. 提議自動推進 phase 4 → still phase 4 (Stage 2 in progress) 或 5

注意：admin 改 deliverable 的 API 還沒有，這是個 gap。短期可以用 Insforge db query。

## 場景 D — 新增 deliverables

用戶說「派阿丁做協作徵稿平台 Stage 2 — 後台審稿、月曆視圖、Google Login」

1. 撈 ading 的 engineer.id
2. 確認協作徵稿平台 primary_engineer_id 是不是 ading、不是就 PATCH 改
3. 用 Insforge SDK / db query 批次 INSERT deliverables (現在沒專屬 admin API):
   ```bash
   # 用 cli 跑
   cd /Users/linjunrong/Desktop/test/waiting-list/feature8_project_dashboard
   npx @insforge/cli db query "
   INSERT INTO deliverables (case_id, stage, description, engineer_id, due_date, handoff_notes) VALUES
   ('<case_id>', 2, '後台審稿', '<ading_id>', NULL, NULL),
   ('<case_id>', 2, '月曆視圖', '<ading_id>', NULL, NULL),
   ('<case_id>', 2, 'Google Login', '<ading_id>', NULL, NULL);
   "
   ```

---

# notes 累加規則

不要覆蓋，append + 時間戳：
```
原: "需求書 v3 已交、報價 30K 已成交。等你方決定稅務後寄合約。"
追加 "合約簽回，訂金已入帳" →
"需求書 v3 已交、報價 30K 已成交。等你方決定稅務後寄合約。

[2026-05-17] 合約簽回，訂金已入帳。"
```

---

# 錯誤處理

| 現象 | 處理 |
|---|---|
| 401 unauthorized | grep 重拿 TOKEN |
| 404 not found | UUID 錯、重撈 cases list |
| 503 / Insforge service issue | 提醒用戶 prod 可能掛 / claim 過期 |
| 連線失敗 | 換 DEV_URL 試本機 |

---

# 重點原則

1. **永遠 show diff、絕不默默改**
2. **一句話兩案 → 拆兩次提議**
3. **notes 是 append、不是覆蓋**
4. **不確定 match → 問用戶**
5. **跑完報結果 + dashboard 連結**
6. **新案 SOP：建 case → 自動產 3 期 → 指派工程師 → 加 deliverables（可選）**
