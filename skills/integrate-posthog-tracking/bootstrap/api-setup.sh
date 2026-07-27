#!/usr/bin/env bash
# PostHog 一鍵 bootstrap：啟用 6 個 toggle + 建 funnel + trend + dashboard
# 用法：
#   bash api-setup.sh phx_PERSONAL_KEY 471715 "協作徵稿平台"
#   bash api-setup.sh phx_xxx <project_id> "<project_display_name>"
#
# 沉澱自協作徵稿平台 案 2026-06-16、跨案可直接抄

set -euo pipefail

KEY="${1:?usage: $0 PERSONAL_API_KEY PROJECT_ID DISPLAY_NAME}"
PID="${2:?missing project id}"
NAME="${3:?missing display name}"
HOST="${POSTHOG_HOST:-https://us.posthog.com}"

echo "→ project id=$PID, name=$NAME, host=$HOST"

# ────────────────────────────────────────
# 1. 啟用 6 個 toggle + 改 project name
# ────────────────────────────────────────
echo "→ 啟用 toggle (session_recording / heatmaps / autocapture / exceptions / performance / console_log) + 改名"
curl -s -X PATCH -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
  "$HOST/api/projects/$PID/" \
  -d "{
    \"name\": \"$NAME\",
    \"autocapture_opt_in\": true,
    \"session_recording_opt_in\": true,
    \"heatmaps_opt_in\": true,
    \"capture_console_log_opt_in\": true,
    \"capture_performance_opt_in\": true,
    \"autocapture_exceptions_opt_in\": true
  }" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(f'   ✓ project name: {d.get(\"name\")}')"

# ────────────────────────────────────────
# 2. 建 3 個 insight（funnel + trend + reject breakdown）
# ────────────────────────────────────────
mkresp() { python3 -c "import json,sys; print(json.load(sys.stdin)['id'])"; }

echo "→ 建 funnel: 投稿漏斗"
FUNNEL_ID=$(curl -s -X POST -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
  "$HOST/api/projects/$PID/insights/" \
  -d '{
    "name": "投稿漏斗",
    "description": "100 人開頁 → 選照片 → 按送出 → 成功",
    "query": {
      "kind": "InsightVizNode",
      "source": {
        "kind": "FunnelsQuery",
        "series": [
          {"kind": "EventsNode", "event": "$pageview", "name": "開 /submit", "properties": [{"key": "$pathname", "value": "/submit", "operator": "exact", "type": "event"}]},
          {"kind": "EventsNode", "event": "photo_upload_attempted", "name": "選了照片"},
          {"kind": "EventsNode", "event": "submission_attempted", "name": "按了送出"},
          {"kind": "EventsNode", "event": "submission_succeeded", "name": "成功投稿"}
        ],
        "dateRange": {"date_from": "-7d"},
        "funnelsFilter": {"funnelVizType": "steps", "funnelWindowInterval": 1, "funnelWindowIntervalUnit": "hour"}
      }
    },
    "saved": true
  }' | mkresp)
echo "   ✓ funnel id=$FUNNEL_ID"

echo "→ 建 trend: 每日成功投稿數"
TREND_ID=$(curl -s -X POST -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
  "$HOST/api/projects/$PID/insights/" \
  -d '{
    "name": "每日成功投稿數",
    "description": "看每天有幾人成功送出",
    "query": {
      "kind": "InsightVizNode",
      "source": {
        "kind": "TrendsQuery",
        "series": [{"kind": "EventsNode", "event": "submission_succeeded", "name": "成功投稿", "math": "total"}],
        "dateRange": {"date_from": "-14d"},
        "interval": "day"
      }
    },
    "saved": true
  }' | mkresp)
echo "   ✓ trend id=$TREND_ID"

echo "→ 建 trend: 上傳被拒原因分布"
REJ_ID=$(curl -s -X POST -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
  "$HOST/api/projects/$PID/insights/" \
  -d '{
    "name": "上傳被拒原因分布",
    "description": "前端 reject 用戶照片的原因（too_large / not_image / too_many）",
    "query": {
      "kind": "InsightVizNode",
      "source": {
        "kind": "TrendsQuery",
        "series": [{"kind": "EventsNode", "event": "photo_upload_rejected", "name": "被拒", "math": "total"}],
        "dateRange": {"date_from": "-7d"},
        "breakdownFilter": {"breakdown": "reason", "breakdown_type": "event"}
      }
    },
    "saved": true
  }' | mkresp)
echo "   ✓ reject breakdown id=$REJ_ID"

# ────────────────────────────────────────
# 3. 建 dashboard、把 3 個 insight 收進去
# ────────────────────────────────────────
echo "→ 建 dashboard"
DASH_ID=$(curl -s -X POST -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
  "$HOST/api/projects/$PID/dashboards/" \
  -d "{
    \"name\": \"$NAME · 投稿監控\",
    \"description\": \"每日一眼：訪客→投稿轉換、每日成功數、被拒原因\"
  }" | mkresp)
echo "   ✓ dashboard id=$DASH_ID"

for ID in $FUNNEL_ID $TREND_ID $REJ_ID; do
  curl -s -X PATCH -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' \
    "$HOST/api/projects/$PID/insights/$ID/" \
    -d "{\"dashboards\": [$DASH_ID]}" >/dev/null
done
echo "   ✓ 3 insights attached to dashboard"

echo ""
echo "════════════════════════════════════════"
echo "✅ 全部完成"
echo "════════════════════════════════════════"
echo "  Dashboard:  $HOST/project/$PID/dashboard/$DASH_ID"
echo "  Funnel:     $HOST/project/$PID/insights/(id=$FUNNEL_ID)"
echo "  Trend:      $HOST/project/$PID/insights/(id=$TREND_ID)"
echo "  Reject:     $HOST/project/$PID/insights/(id=$REJ_ID)"
echo ""
echo "下一步：客戶端跑投稿、5-30 分鐘後 dashboard 開始有數據"
