#!/usr/bin/env bash
# meeting-to-pm-spec / transcribe
# 影片或音檔 → meeting_transcript.txt + meeting_transcript.srt
# Usage: transcribe.sh <input_media> <out_dir>
#
# 為什麼預設切 chunk：
# whisper.cpp 對長音檔（>20 分）在某些噪音/音樂/靜音段會進入 hallucination 迴圈，
# 連續輸出 "(字幕:貓)" / "(字幕:組)" 直到結尾不再恢復。切 10 分鐘 chunk 分別跑可避免。
# 沉澱自 線上課程客戶 案 2026-06-07 對稿會議（58 分鐘影片整段跑壞）的修法。

set -euo pipefail

INPUT="${1:?need input path}"
OUTDIR="${2:?need out dir}"
LANG="${LANG_OVERRIDE:-zh}"
CHUNK_MIN="${CHUNK_MIN:-10}"   # 每段幾分鐘，預設 10

MODEL="${WHISPER_MODEL:-$HOME/Documents/Codex/2026-06-03/https-drive-google-com-drive-u/models/ggml-small.bin}"

if [ ! -f "$MODEL" ]; then
  echo "❌ Whisper model not found: $MODEL" >&2
  echo "下載：curl -L -o ~/.cache/whisper/ggml-small.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin" >&2
  exit 1
fi

for cmd in whisper-cli ffmpeg ffprobe; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "❌ $cmd not found. Install: brew install whisper-cpp ffmpeg" >&2
    exit 1
  fi
done

mkdir -p "$OUTDIR"
BASE="$OUTDIR/meeting_transcript"
TMP=$(mktemp -d -t m2pm-XXXXXX)
trap "rm -rf $TMP" EXIT

# 抓總長度（秒）
DURATION_SEC=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT" | awk '{print int($1)}')
CHUNK_SEC=$((CHUNK_MIN * 60))
NUM_CHUNKS=$(( (DURATION_SEC + CHUNK_SEC - 1) / CHUNK_SEC ))

echo "▶ Input: ${DURATION_SEC}s, splitting into ${NUM_CHUNKS} × ${CHUNK_MIN}-min chunks"

# 切 chunk + transcribe
{
  for i in $(seq 0 $((NUM_CHUNKS - 1))); do
    START=$((i * CHUNK_SEC))
    START_MIN=$((START / 60))
    END_MIN=$(( (START + CHUNK_SEC) / 60 ))
    [ $END_MIN -gt $((DURATION_SEC / 60 + 1)) ] && END_MIN=$((DURATION_SEC / 60))
    CHUNK_WAV="$TMP/chunk_$i.wav"
    CHUNK_OUT="$TMP/chunk_$i"

    echo "▶ chunk $i: ${START_MIN}-${END_MIN} min" >&2
    ffmpeg -y -ss $START -t $CHUNK_SEC -i "$INPUT" \
      -ar 16000 -ac 1 -c:a pcm_s16le "$CHUNK_WAV" \
      -hide_banner -loglevel error

    whisper-cli -m "$MODEL" -f "$CHUNK_WAV" -l "$LANG" \
      -otxt -osrt -of "$CHUNK_OUT" 2>/dev/null

    echo ""
    echo "=== [${START_MIN}:00 - ${END_MIN}:00] ==="
    cat "${CHUNK_OUT}.txt"
  done
} > "${BASE}.txt"

# 拼接 SRT 並調整時間戳
{
  IDX=1
  for i in $(seq 0 $((NUM_CHUNKS - 1))); do
    CHUNK_SRT="$TMP/chunk_$i.srt"
    [ ! -f "$CHUNK_SRT" ] && continue
    OFFSET_SEC=$((i * CHUNK_SEC))
    # 用 python 處理 SRT 偏移（awk 處理時分秒太繞）
    python3 -c "
import sys, re
offset = $OFFSET_SEC
idx = $IDX
content = open('$CHUNK_SRT').read()
def shift(match):
    h, m, s, ms = map(int, [match.group(1), match.group(2), match.group(3), match.group(4)])
    total_ms = (h*3600 + m*60 + s) * 1000 + ms + offset * 1000
    nh = total_ms // 3600000
    nm = (total_ms % 3600000) // 60000
    ns = (total_ms % 60000) // 1000
    nms = total_ms % 1000
    return f'{nh:02d}:{nm:02d}:{ns:02d},{nms:03d}'
content = re.sub(r'(\d{2}):(\d{2}):(\d{2}),(\d{3})', shift, content)
print(content, end='')
"
  done
} > "${BASE}.srt"

# Sanity check：unique 行數 < 5 → 整個壞掉
UNIQ_LINES=$(grep -v "^===" "${BASE}.txt" | grep -v "^$" | sort -u | wc -l | tr -d ' ')
TOTAL_LINES=$(wc -l < "${BASE}.txt" | tr -d ' ')

if [ "$UNIQ_LINES" -lt 5 ]; then
  echo "❌ Transcription suspicious: only $UNIQ_LINES unique lines out of $TOTAL_LINES" >&2
  echo "   Likely Whisper hallucination loop. Check audio levels with: ffmpeg -i <input> -af volumedetect -f null -" >&2
  exit 1
fi

echo "✓ ${BASE}.txt ($TOTAL_LINES lines, $UNIQ_LINES unique)"
echo "✓ ${BASE}.srt"
