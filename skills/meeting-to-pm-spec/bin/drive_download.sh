#!/usr/bin/env bash
# meeting-to-pm-spec / drive_download
# 從 Google Drive 資料夾或檔案連結，用 rclone 拉到本機。
# Usage:
#   drive_download.sh <drive_url_or_folder_id> <out_dir> [filename_pattern]
#
# 範例：
#   drive_download.sh "https://drive.google.com/drive/u/0/folders/16LYXWdBZmppI6TqNQVQMLald6Lk4J8LF" /tmp/dl
#   drive_download.sh 16LYXWdBZmppI6TqNQVQMLald6Lk4J8LF /tmp/dl "May*Recording*"
#
# 前提：rclone remote 名稱為 "gdrive"（用 `rclone config create gdrive drive scope=drive config_is_local=true` 建好）。

set -euo pipefail

INPUT="${1:?need drive url or folder id}"
OUT="${2:?need out dir}"
PATTERN="${3:-*}"
REMOTE="${RCLONE_REMOTE:-gdrive}"

# 解析 folder ID（從各種 Drive URL 形式）
if [[ "$INPUT" == http* ]]; then
  # https://drive.google.com/drive/u/0/folders/XXX  /folders/XXX  /drive/folders/XXX
  FOLDER_ID=$(echo "$INPUT" | grep -oE 'folders/[a-zA-Z0-9_-]+' | head -1 | sed 's|folders/||')
  if [ -z "$FOLDER_ID" ]; then
    # /file/d/XXX/view  —— 單一檔案
    FILE_ID=$(echo "$INPUT" | grep -oE 'file/d/[a-zA-Z0-9_-]+' | head -1 | sed 's|file/d/||')
    if [ -n "$FILE_ID" ]; then
      echo "❌ 單一檔案連結請改用 gdown：gdown 'https://drive.google.com/uc?id=$FILE_ID' -O $OUT/" >&2
      exit 1
    fi
    echo "❌ 無法解析 Drive URL：$INPUT" >&2
    exit 1
  fi
else
  FOLDER_ID="$INPUT"
fi

mkdir -p "$OUT"

# 檢查 remote 是否存在
if ! rclone listremotes 2>/dev/null | grep -q "^${REMOTE}:"; then
  echo "❌ rclone remote '${REMOTE}' 未設定。執行：" >&2
  echo "   rclone config create ${REMOTE} drive scope=drive config_is_local=true" >&2
  exit 1
fi

echo "▶ 從 Drive folder $FOLDER_ID 拉檔到 $OUT (pattern: $PATTERN)"

rclone copy "${REMOTE}:" "$OUT" \
  --drive-root-folder-id "$FOLDER_ID" \
  --include "$PATTERN" \
  --max-depth 1 \
  -P 2>&1 | tail -10

echo ""
echo "✓ 下載完成。檔案："
ls -lh "$OUT"
