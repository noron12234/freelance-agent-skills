---
name: apply-client-doc-changes
description: 客戶把 Word / Google Doc 改稿傳來時，自動解析「黃色標記 / 刪除線」並批次套用到正在維運的網站 source code。一條龍：Google Doc URL → 拉 docx → python-docx 解析 highlight + strike → 對應 source code 位置 → 批次 Edit → commit → vercel --prod。觸發詞：「客戶傳 word 改稿」「黃色標記」「刪除線」「套用文件」「把文字一模一樣搬過來」「對照 Word 把內容更新」。沉澱自 2026-06-13 協作徵稿平台 案合作窗口 6/13 doc 77 處黃字 + 34 處刪除線完整套用實戰。
---

# apply-client-doc-changes — 客戶 Doc 改稿一條龍套用

## 用一次馬上回本的工具

接案做維運型網站，最常遇到的情境：客戶不會用 GitHub、也不會自己改 code，他們的「改稿方式」就是：

1. 拿一份 Word / Google Doc
2. 在裡面用**黃色 highlight 標「新增的字」**
3. 用**刪除線標「不要的字」**
4. 寄給你 → 你照改

過去做法是「人眼掃一遍、手動逐個對照 source code」——77 處改動可以做 2 小時。本 skill 把整個流程自動化到 **15 分鐘以內**。

---

## 觸發情境

當用戶說以下任一句，立刻觸發本 skill：

- 「客戶傳了 Word 過來、把文字一模一樣搬過來」
- 「對照 doc 把內容更新」
- 「黃色標記的部分是他新改的」
- 「裡面所有的文字全部套用到我們這側」
- 「文字一定都要有」
- 給你一個 `docs.google.com/document/d/...` 連結 + 改稿描述

---

## 一條龍 5 步

### Step 1 · 拿到 docx（不要請用戶手動下載）

```bash
DOC_ID="<從 Google Doc URL 抽出 /document/d/{ID}/edit 中的 ID>"
OUT="/tmp/client-doc-${DOC_ID}.docx"
curl -sL -o "$OUT" -w "http=%{http_code} size=%{size_download}\n" \
  "https://docs.google.com/document/d/${DOC_ID}/export?format=docx"
file "$OUT"  # 確認是 "Microsoft Word 2007+"
```

- 「擁有連結者可檢視」設定的 doc 都能直接抓
- HTTP 200 + size > 10KB + file type 對 = 成功
- 失敗時請用戶確認「擁有連結者可檢視」or 給你 `.docx` 檔本機路徑

### Step 2 · 解析黃字 + 刪除線 + 嵌入圖片

```python
from docx import Document
import zipfile

d = Document("/tmp/client-doc-XXX.docx")

# Helper：取每段的 yellow text + strike text
def analyze(p):
    yellow = "".join(r.text for r in p.runs
                     if r.font.highlight_color
                     and "YELLOW" in str(r.font.highlight_color))
    strike = "".join(r.text for r in p.runs if r.font.strike)
    return yellow, strike

# 印全文 + 標記類型
print("=== 黃字段落（新增/修改）===")
for i, p in enumerate(d.paragraphs):
    y, _ = analyze(p)
    if y.strip():
        print(f"★ [{i}] {p.text}")

print("\n=== 刪除線段落（要砍）===")
for i, p in enumerate(d.paragraphs):
    _, s = analyze(p)
    if s.strip():
        print(f"✂ [{i}] full: {p.text}")
        print(f"      strike: {s}")

# 嵌入圖片（若有）
with zipfile.ZipFile("/tmp/client-doc-XXX.docx") as z:
    media = [n for n in z.namelist() if n.startswith("word/media/")]
    print(f"\n嵌入圖片 {len(media)} 張")
    for n in media:
        print(f"  · {n}")
```

**關鍵發現**：很多時候 docx 內**沒有實際嵌入圖片**，只有檔名提示（例：`0303-蕭蕊(4)-希望放他跟陸小芬合照那張`）。看到 0 張嵌入圖時馬上告訴用戶「圖檔在哪？」不要自己亂找。

### Step 3 · 對應 source code 位置（mapping）

用戶通常給的 doc 是按「網站區塊」分節（區塊 01 Hero、區塊 02 關於、區塊 03 …）。source code 通常也對應有相同邊界（`export function Hero()`、`export function About()`）。

```bash
# 找區塊邊界
grep -n "^export function\|// ─" src/components/calendar/Sections.tsx | head -30
```

**對應表 inventory 範本**（給用戶 review 前必出）：

| 區塊 | doc 段落 | source code 位置 | 需要動作 |
|---|---|---|---|
| 01 Hero | ★[14, 21, 28] | Sections.tsx HeroG (855-1337) | 套黃字 + 改 CTA |
| 02 關於 | ★[34-47] | KaleidoConcept (1338-) | eyebrow 改、stats 加 row、加小註 |
| 05 法律 | ✂[128-148] 整段 strike | 從 layout 拿掉 | 投稿頁拿掉 import |
| ... | | | |

**重要**：先給用戶這張表「**這是我即將動手的 scope**」、確認後再開做。比動完才發現方向錯省時間。

### Step 4 · 批次 Edit（順序很重要）

按危險度由低到高：

1. **新增的文字**（最安全）— eyebrow、小註、副標
2. **修改的標題 / 主標**（中）— h1 / h2 替換
3. **刪除的區塊**（最後）— 整段拿掉、可能影響 layout
4. **新增的欄位**（form 等）— 要加 state、validation、API payload

**Edit 順序鐵則**：
- 每個區塊改完馬上 `curl localhost/page` 確認沒 build error
- 不要全改完才驗
- 遇到 ambiguous（doc 字眼模糊）→ 馬上問用戶、不要猜

### Step 5 · Commit + deploy

```bash
git add <touched files only>
git commit -m "feat(<project>): 套用 <客戶> <date> doc 全網站文案 + <其他改動>

doc strikethrough 拿掉：
- <list>

doc 黃字新增/修改：
- <list>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"

# Vercel prod 部署（calendar 案規矩：前台改動要明確授權；其他案依各 case 規則）
vercel --prod --yes
```

---

## 常見坑

### 坑 1：docx 「沒有嵌入圖片」、只有檔名提示
- 客戶的 doc 通常只標檔名（`0303-蕭蕊.jpg`）、不附實檔
- 不要花 30 分鐘 grep 本機找——直接問用戶「圖在哪？LINE / Drive / 還沒給？」
- 用戶說「先跳過」就先用 placeholder SVG（見坑 4）

### 坑 2：DB 內的舊資料 vs doc 新版
- 例：tag 列表 doc 列了 14 個、但 DB 有 8 個舊 tag
- 不要碰 DB（風險高）、改 source code 加 `FALLBACK_TAGS` 寫死蓋掉
- 後台之後再清 DB

### 坑 3：「對外不要有 doc 內部口吻」
- doc 內常有「▸ 賣點 02」「▸ 左側段落 1」這種給設計師看的標記
- **這些字不要進 source code**，只有「實際內容」要進

### 坑 4：圖檔不符時的暫代方案
- 若 doc 範例故事文案是 A（阿嬤喝咖啡）、但圖還是 B（便當盒）→ 圖文不符
- 寫一張對應文案的 SVG illustration 當 placeholder（暖咖啡杯+蒸氣+戒指手）
- 等用戶提供實檔再覆蓋

### 坑 5：CSS 改了 dev server 沒重 build
- Turbopack CSS HMR 有時 cache 卡住
- 不要花時間 debug、直接 commit 推 prod（Vercel 會重 build）
- prod 一定會抓最新 globals.css

### 坑 6：「用戶說刪掉、但 doc 沒這條」
- 例：用戶說「全部編輯點評刪除」、查 doc 真的沒這條 → 用戶在問「我漏看了嗎」or「直接砍掉」
- 確認方式：用戶語氣短促 + phrasing 暗示 = 砍掉
- 動手前用一行確認「OK 我把它砍了，doc 沒提到 + 你說不要 → 拿掉」

---

## 同場加映：多 layout 給客戶選

接案做網站改版，最有效的「降低重做風險」做法不是「我猜對客戶要哪種」、是**做 N 個方向同個 section 並存、加一個 toolbar 讓客戶切**：

```tsx
type Layout = "cards" | "split" | "spectrum" | "wheel";

export function StorySection() {
  const [layout, setLayout] = useState<Layout>("cards");  // 預設推薦的

  return (
    <section>
      {/* 主標 / eyebrow */}
      <LayoutSwitcher layout={layout} setLayout={setLayout} />
      {layout === "cards" && <CardsGrid />}
      {layout === "split" && <SplitView />}
      {layout === "spectrum" && <Spectrum />}
      {layout === "wheel" && <Wheel />}
    </section>
  );
}

function LayoutSwitcher({ layout, setLayout }) {
  return (
    <div role="tablist">
      <span>選擇呈現方式</span>  {/* 友善文字、不要寫「REVIEW」「DEV」 */}
      {(["cards","split","spectrum","wheel"] as Layout[]).map(opt => (
        <button
          key={opt}
          aria-selected={opt === layout}
          onClick={() => setLayout(opt)}
        >
          {LABELS[opt]}
        </button>
      ))}
    </div>
  );
}
```

- 客戶確認方向後可移除 toolbar、留下 1 個 layout
- 但「移除」前先讓客戶選 → user 體驗最好
- 重要：toolbar 文字要對客戶友善（`選擇呈現方式` > `REVIEW`）

---

## 同場加映：Mobile audit 系統化

每次改完都要做：

```bash
# 1. mobile viewport
# Playwright resize 390x844 (iPhone 14 Pro)

# 2. 逐 section 截圖 (10-15 張)
#    Hero / Concept / Product / Stories / Benefits / HowItWorks / Timeline / CTA / Footer
#    /submit 全頁 (SampleStory / form top / date / body / tags / photo / address / consent / aside)

# 3. 列問題清單，常見問題：
#    - desktop 3 欄 grid 在 mobile 沒 fallback → 字斷成 4 行
#    - hero CTA 跟 MobileFloatingCta 重複出現
#    - timeline 時間欄 minmax 太寬、留太多空白
#    - countdown 4 個數字 flex wrap 被切 → 改 2x2 grid
#    - footer inline link 被 a[href="/submit"] 全域 selector 套到 ctaGlowPulse

# 4. 批次修：給 inline-style div 加 className，加 media query @media (max-width: 768px)
# 5. CSS rule 一定要加 !important（要打贏 inline style）
```

---

## 速查 cheat sheet

| 動作 | 指令 |
|---|---|
| Google Doc → docx | `curl -sL -o /tmp/x.docx "https://docs.google.com/document/d/$ID/export?format=docx"` |
| 解析黃字 + 刪除線 | python-docx + `r.font.highlight_color` + `r.font.strike` |
| 找 source code 區塊邊界 | `grep -n "^export function" src/.../Sections.tsx` |
| dev CSS 卡住 → 直接推 prod | `vercel --prod --yes`（Vercel build 會重編 CSS） |
| 部署狀態驗證 | `curl -sI "https://your-project.vercel.app/" \| head -3` |
| 案件密碼速查 | Spotlight 搜「速查」→ `~/Desktop/速查-接案網址密碼.md` |

---

## 反思紀律

這個 skill 沉澱自 2026-06-13 協作徵稿平台案 8 區塊 / 77 黃字 / 34 刪除線完整實戰，總耗時約 90 分鐘。下次同類任務目標 < 30 分鐘。

每次做完後問自己 3 個問題：
1. 有沒有新的 sed 命令、新的 grep pattern、新的 cliff 值得加進 cheat sheet？
2. 有沒有踩到「對 doc 文字過度詮釋」的坑？（doc 直譯比意譯安全）
3. 有沒有把「給客戶選方向」做在前面、避免重做？

把答案 commit 進這份 SKILL.md。
