---
name: gen-ai-hero-video
description: 接案網站要做「動感 hero 主視覺」時，用 AI 影片生成平台（Kling / Runway / Luma / Hailuo）跑 image-to-video，接到 Next.js `<video>` 標籤 + mobile fallback。涵蓋：平台選型對照、中英文 prompt 範本、靜圖→影片→部署的完整流程、6 種常見 hero 視覺類型對應的 prompt、計費結構（含影片轉素材費的接案報價）、Spline 真 3D 對照。觸發詞：「hero 動起來」「主視覺要動」「萬花筒動畫」「3D 動畫」「AI 影片」「動態 banner」「image to video」「跑個影片」「主視覺活化」。沉澱自 2026-06 協作徵稿平台 案 hero 萬花筒影片實驗 + Runway / Kling / Luma 三平台實測。
---

# gen-ai-hero-video — AI 影片 hero 主視覺一條龍

## 一句話

客戶給你一張靜態主視覺、你把它丟進 AI image-to-video 平台、4 秒內動起來、接到網站當 hero 背景影片。

**不是真 3D，是 AI 算出來的動態影片**（mp4）。真 3D（即時渲染）見最後一段。

---

## 觸發情境

- 「hero 太靜了、想要動起來」
- 「我這張主視覺能不能動」
- 「客戶想要那種會動的萬花筒 / 流光 / 粒子」
- 「AI 影片」「3D 動畫」「動態 banner」
- 「主視覺活化」「跑個 4 秒影片」

---

## 5 步流程（從靜圖到 prod）

### Step 1 · 確認素材
- 客戶有沒有現成主視覺 .jpg / .png？
- 解析度 ≥ 1024×1024 才好用
- **沒有**就先用 Midjourney / DALL-E / Imagen 4 產一張、prompt 範本見後段
- **構圖原則**：中央留主體、四周留呼吸（讓動效有空間發揮）

### Step 2 · 選平台（依需求）

| 平台 | 強項 | 適合 | 計費 | 中文 prompt |
|---|---|---|---|---|
| **Kling AI**（快手）| 動作流暢、便宜、5-10s | 接案 hero 影片 default | ~¥66/月 60 影片 | ⭐⭐⭐⭐⭐ |
| **Runway Gen-3** | 電影質感、攝影機運動細膩 | 高端品牌 hero | $12/月 125 credits | ⭐⭐⭐ |
| **Luma Dream Machine** | image-to-video 最自然 | 把現有靜圖活化 | $9.99/月 30 影片 | ⭐⭐⭐⭐ |
| **Hailuo / MiniMax** | 免費額度大、中文友善 | 試方向不付費 | 免費起 | ⭐⭐⭐⭐⭐ |
| **Pika 2.0** | 角色一致性好 | 帶人物的 hero | $10/月 | ⭐⭐⭐ |
| **Veo 3**（Google） | 質感頂級、含原生音效 | 預算充足、要對嘴 | Gemini Ultra | ⭐⭐⭐⭐ |

**接案 default 推薦**：**Kling**（CP 值最高）→ 不行再加 **Luma**（image-to-video 質感）→ 高端案再 **Runway**。

### Step 3 · 跑 image-to-video

進平台 → upload 靜圖 → 寫 prompt → 4-10 秒影片出來。

**prompt 結構（中文範本）**：
```
[主體動作] + [攝影機運動] + [光線變化] + [氛圍] + [時長]

例（協作徵稿平台萬花筒 hero）：
萬花筒緩慢旋轉，色片從中心向外綻放，攝影機微微推近，
暖色光線從中央流出，紙感顆粒感，editorial 風格，4 秒
```

**prompt 結構（英文範本）**：
```
[Subject motion] + [Camera movement] + [Light] + [Mood] + [Style] + [Duration]

例：
Kaleidoscope slowly rotating, color shards blooming outward from center,
camera dolly in subtly, warm light flare from center, paper grain texture,
editorial magazine aesthetic, 4 seconds, cinematic
```

**6 種常見 hero 影片 prompt 範本**：

```
1. 萬花筒 / 旋轉對稱：
   "slow kaleidoscopic rotation, mandala unfolding,
    soft light flare radiating outward, 4s, dreamlike"

2. 流光 / liquid metal：
   "liquid gold flowing across surface, ripples spreading,
    soft caustic light, slow motion, 5s, elegant"

3. 粒子 / particle：
   "golden particles floating slowly, gentle drift,
    out of focus background, depth of field, 5s, magical"

4. 紙感翻動：
   "paper pages turning gently, soft fold animation,
    natural light from above, vintage editorial, 4s"

5. 風 / 自然元素：
   "tall grass swaying in soft wind, golden hour light,
    slight camera drift, peaceful, 6s"

6. 故障 / glitch：
   "subtle digital glitch effect, color separation,
    chromatic aberration, edgy modern, 3s"
```

### Step 4 · 後製（選用）

- 影片裁切：用 `ffmpeg -ss 0 -t 4 -an input.mp4 output.mp4` 切時長 + 拿掉音軌
- 縮小檔：`ffmpeg -i input.mp4 -vcodec libx264 -crf 28 -preset slower -vf "scale=1280:-2" output.mp4`
  - 目標：< 1MB（mobile 友善）
- WebP / AV1（高階）：bitrate 再降一半

### Step 5 · 接進網站

**Next.js 樣板**：

```tsx
// Hero section
<section className="hero">
  {/* 影片背景 */}
  <video
    autoPlay
    loop
    muted
    playsInline
    poster="/hero-poster.jpg"  // fallback 靜圖、影片載入前先顯示
    className="hero-video"
  >
    <source src="/hero.mp4" type="video/mp4" />
    {/* 沒影片支援的瀏覽器靠 poster */}
  </video>

  {/* 蓋一層暗化讓文字可讀 */}
  <div className="hero-overlay" />

  {/* 文字內容 */}
  <div className="hero-content">
    <h1>同一天，看見不同的光</h1>
  </div>
</section>
```

```css
.hero { position: relative; min-height: 80vh; overflow: hidden; }
.hero-video {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  z-index: 0;
}
.hero-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(0,0,0,0.2) 0%, rgba(0,0,0,0.55) 100%);
  z-index: 1;
}
.hero-content { position: relative; z-index: 2; padding: 80px 40px; }

/* mobile：弱機 / 慢網路關影片、改靜圖 */
@media (max-width: 768px) and (prefers-reduced-motion: no-preference) {
  /* 行動裝置仍播，但檔案要 < 500KB */
}
@media (prefers-reduced-motion: reduce) {
  .hero-video { display: none; }
  .hero { background: url('/hero-poster.jpg') center/cover; }
}
```

**檔案放哪**：
- `public/hero.mp4`（影片本體）
- `public/hero-poster.jpg`（影片載入前 + reduced-motion fallback）

**部署檢查**：
- 影片 < 1MB（mobile）
- `playsinline` 一定要加（iOS Safari 才會 inline 播放、不會全螢幕）
- `muted` 必加（chrome autoplay 政策）

---

## 接案計費策略

把 AI 影片當「視覺資產加值」加進報價：

| 項目 | 報價區間 |
|---|---|
| 1 支 hero 影片（4-6s）含 prompt 試 3 輪 + 後製 + 接到網站 | NT$ 4,000 – 8,000 |
| 1 整套（hero + 2 個 section 背景）| NT$ 10,000 – 18,000 |
| 含原始靜圖生成（Midjourney + 客戶 brief 對齊） | + NT$ 3,000 |

**重點**：不要把 AI 平台月費當成本灌進去（你會用一整月跑很多案）、報「視覺資產費」。

**對外溝通話術**：
- ❌「我用 AI 生影片」
- ✅「我用 image-to-video 技術讓你的主視覺活起來」
- ✅「動態視覺資產」

---

## 協作徵稿平台 案實戰參考

`feature{N}_client_project/web/public/` 已有 11 支萬花筒影片：

```
kaleido-a1.mp4 ~ kaleido-e1.mp4  (各 variant 主版本)
kaleido-p1.mp4 ~ kaleido-p5.mp4  (preview hub 用)
kaleido-source.jpg               (原始靜圖)
main-visual-square.jpg           (1010×1010 萬花筒)
```

生成腳本：`web/scripts/gen-kaleido-video.mjs`（這支可以參考改寫成其他案用）

---

## 真 3D（即時渲染、不是影片）

如果客戶要「可互動的 3D」、不是固定影片：

| 工具 | 適合 | 缺點 |
|---|---|---|
| **Spline**（spline.design）| 拖拉做 3D scene、export web component | 載入慢（~2MB）、SEO 弱、字體支援差 |
| **Three.js + React Three Fiber** | 完全自訂、performance 最好 | 工程量大、需要 3D 模型素材 |
| **Rive** | 2D/2.5D 角色動畫、互動 | 不是真 3D、但檔案超小（KB 級） |

**接案實話**：90% 的案子用 AI 影片就夠了。Spline 只在客戶明確要「滑鼠互動 3D」時用。一般 hero 動感影片更可靠。

---

## 常見坑

### 坑 1：影片自動播放被擋
- iOS Safari：必須 `muted` + `playsinline`
- Chrome：必須 `muted`
- 任何缺失都會 silently fail、影片不動

### 坑 2：影片檔太大、mobile 慢網路爆 LCP
- hero 影片目標 < 1MB
- 用 `<link rel="preload" as="video">` 預載
- 或用 `<picture>` + WebP poster、影片 lazy load

### 坑 3：AI 生影片有「鬼影 / morph」
- prompt 加 `coherent motion, no morphing, no artifacts`
- 或時長縮短到 3-4s（越短越穩）
- 嚴重的話換另一張靜圖重跑

### 坑 4：客戶 brief「想要動但不知道怎麼動」
- 給 6 種 prompt 範本選（旋轉 / 流光 / 粒子 / 紙感 / 風 / 故障）
- 試 3 個方向各跑一支、給客戶選
- 不要跑一個就 push 給客戶

### 坑 5：mobile data 用爆客戶手機
- Next.js: 加 `<video>` 的 `preload="metadata"` 不要 preload="auto"
- 或 mobile 直接用 `<picture>` poster 靜圖、桌面才 video

---

## 速查 cheat sheet

| 動作 | 指令 / 連結 |
|---|---|
| Kling AI | https://klingai.com (中文 prompt 友善) |
| Runway Gen-3 | https://runwayml.com |
| Luma Dream Machine | https://lumalabs.ai/dream-machine |
| Hailuo | https://hailuoai.video (免費試) |
| Veo 3 | Gemini app inside |
| 影片裁切 | `ffmpeg -ss 0 -t 4 -an in.mp4 out.mp4` |
| 影片壓縮 | `ffmpeg -i in.mp4 -vcodec libx264 -crf 28 -vf "scale=1280:-2" out.mp4` |
| 看 mp4 metadata | `ffprobe -v error -show_format in.mp4` |

---

## 下次接到「hero 要動」需求時

1. 問清楚：「動的感覺要哪一類？」（旋轉 / 流光 / 粒子 / 紙感 / 風 / 故障）
2. 客戶現有主視覺有嗎？沒有先 Midjourney 產
3. Kling 跑 3 個方向 → 給客戶看 → 選一個 → 細修 2 次
4. ffmpeg 壓 < 1MB
5. Next.js `<video autoPlay loop muted playsInline poster>` 接進去
6. mobile 驗 LCP < 2.5s
7. 帳單列「動態視覺資產」NT$ 4,000–8,000
