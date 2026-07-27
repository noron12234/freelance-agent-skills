---
name: design-pitch-site
description: 接案做著陸頁 / 設計提案網站時用這個。一個 Next.js codebase 跑出多個視覺 variant（?v=d/e/f/g）+ 一頁對外的 /showcase 比稿頁給客戶 / 廠商挑方向。內建「暖色 editorial + 萬花筒 + 紙感 + 多彩文字框」美術系統（次元創意作品等級）。當用戶說「做個比稿網站」「給客戶選方向」「做設計提案頁」「我要把網站給客戶看」「做 landing 給廠商看」時觸發。
---

# 何時用這個 skill

**主動觸發訊號：**
- 「設計提案 / 視覺方向 / 比稿 / 給業主看 / 做 landing / 客戶要驗收」
- 「做個著陸頁 / 我有個新案 / 客戶要看設計 / 多做幾個版本」
- 「我把網站給廠商看 / 給工程師看 / 給對方挑」
- 任何「客戶要在 X 日前看到設計」+ 還沒選定方向的案子

**不要觸發：**
- 客戶已選定方向、要 production-level full implementation（用 `/design-html` 或 frontend-design）
- 純 admin / dashboard 內部工具（沒有比稿需求）
- 已經有 codebase 要改一個小元件（用 Edit 就好）

---

# 第一原則：設計品質的硬底線

引用 memory `feedback_design_quality_bar.md`：
> **Pentagram / IDEO / Linear 等級，灰階也要精緻。不接受陽春線稿。**

意思：
- ❌ 直接生 Tailwind utility classes 拼湊的「看得出是 AI 寫」的版面
- ❌ 全程灰底白卡 + 黑邊框 + Inter 字體（generic SaaS look）
- ❌ 沒設計過的 emoji 當 hero icon
- ✅ 自製 SVG 圖形（kaleidoscope / cassette / 萬花紋）
- ✅ 多彩 offset frame、漸層、紙感網點、scan lines 等手作細節
- ✅ 中英 typography 分軌：襯線中文（Noto Serif TC）+ 幾何數字（Manrope）+ 標籤無襯線（Noto Sans TC）+ mono（JetBrains Mono）
- ✅ 動畫節制但要有 — Reveal scroll fade-up + 元件級的旋轉/脈動

---

# 標準交付物（每個案子至少做到這 4 件）

1. **3–5 個視覺方向 hero 變體** — 同個內容、不同 hero treatment（不是換顏色，是換空間結構）
2. **A `/showcase` 比稿頁** — 對外給客戶 / 廠商挑方向，含 iframe 預覽 + 文字導讀
3. **內容區塊**（所有 variant 共用）：Concept 段、故事/作品卡橫向滑、範例文章（drop cap）、How-to 三步驟、CTA 倒數、Footer
4. **URL 參數 `?v=X`** — 客戶能直接傳特定 variant 給夥伴

---

# 美術系統（DEFAULT — 暖色 editorial）

這套是「萬花筒 × 紙感 × 多彩文字框」配方。當案子主題是文化、出版、藝術、慢生活、文藝復古時用。

## Palette（CSS variables）

```css
:root {
  /* Kaleido 主推 — 暖色 editorial */
  --paper: #f5e8c6;        /* 牛皮紙底 */
  --paper-2: #ecdbb0;
  --paper-3: #dfc790;
  --ink: #2a1a0e;          /* 深褐墨 */
  --ink-2: #4a3220;
  --muted: #a37d55;
  --rule: #c9a878;
  --rule-soft: #dcc098;
  --accent: #e5722e;       /* 朱印橘 */
  --accent-2: #b8501a;
  --card: #fbf2d7;
  --shadow: rgba(180, 80, 30, 0.14);

  /* 多彩 frame 用色（不會隨 palette 切換） */
  --kal-orange: #e5722e;
  --kal-pink: #e27fb8;
  --kal-mustard: #d9a943;
  --kal-cream: #f5e8c6;
  --kal-brown: #a37d55;
  --kal-teal: #5b8a8d;
}
```

替代色票（給客戶選不同氛圍）：
- **paper** 米紙：`#f4ecdc / #1d1916 / #b85c3a / #8c7355`
- **moss** 苔綠：`#ede9d8 / #1f2418 / #5e7142 / #7a7d68`
- **dusk** 暮色：`#efe4d4 / #2a1f2e / #8b3a5c / #826976`
- **ocean** 靛青：`#efeae0 / #1a1d2e / #3a5683 / #6b7280`

## 字體（Next.js next/font）

```ts
import { Manrope, Noto_Sans_TC, Noto_Serif_TC, JetBrains_Mono } from "next/font/google";

const manrope = Manrope({ variable: "--font-display", weight: ["400","500","600","700"] });
const notoSansTC = Noto_Sans_TC({ variable: "--font-sans", weight: ["300","400","500","600"] });
const notoSerifTC = Noto_Serif_TC({ variable: "--font-cn-serif", weight: ["400","500","600","700","900"] });
const jetbrainsMono = JetBrains_Mono({ variable: "--font-mono", weight: ["400","500"] });
```

使用規則：
- **中文標題 / 內文** → `var(--font-cn-serif)` 思源宋體 TC
- **UI 標籤 / 導航 / 副本** → `var(--font-sans)` 思源黑體 TC
- **大數字（倒數、年份、統計）** → `var(--font-display)` Manrope（幾何）
- **編號 / debug code** → `var(--font-mono)` JetBrains Mono

## 紙感網點

```css
.sc-paper-tex {
  background-color: var(--paper);
  background-image:
    radial-gradient(rgba(60, 40, 20, 0.04) 1px, transparent 1px),
    radial-gradient(rgba(60, 40, 20, 0.025) 1px, transparent 1px);
  background-size: 3px 3px, 7px 7px;
  background-position: 0 0, 1px 2px;
}
```

## 元件 primitives（必做）

### 1. Kaleidoscope SVG（12 切片 + 紋理 pattern）

完整版本見 `feature{N}_client_project/web/src/components/calendar/Kaleido.tsx`。
核心結構：
- `<KaleidoDefs>` — 6 種 SVG pattern（halftone / hatch / speckle / scribble / cross / arcs）+ glow radialGradient
- `<Kaleidoscope size={520} rotate={p*90} />` — 12 個 wedge path，每片填純色 + 可選紋理 overlay
- `<LabelPointer side="left" top={50} length={180} label="記憶的碎片" />` — 細線 + 圓點 + 標籤，呼應原設計提案

### 2. FrameStack（多彩 offset 文字框）

```tsx
<FrameStack colors={[FRAME_COLORS[0], FRAME_COLORS[2], FRAME_COLORS[4]]} offset={8}>
  <div>... 卡片內容 ...</div>
</FrameStack>
```

讓子元素背後浮出 2–3 層彩色框，typical offset 5–8 px。

`FRAME_COLORS = ['#d94f3c', '#e8a82c', '#3a86a8', '#5f8d4e', '#7b4ba8', '#d96aa4', '#2e5a8c', '#c95a2c']`

### 3. GeoNumber（幾何大數字）

```tsx
<GeoNumber size={96} color="var(--accent)">365</GeoNumber>
```

```ts
{
  fontFamily: 'var(--font-display), "Manrope", system-ui',
  fontSize: size,
  fontWeight: 600,
  lineHeight: 0.85,
  letterSpacing: '-0.06em',
  fontVariantNumeric: 'tabular-nums',
}
```

### 4. Reveal scroll fade-up

```tsx
function useReveal(threshold = 0.15) {
  const ref = useRef(null);
  const [shown, setShown] = useState(false);
  useEffect(() => {
    if (!ref.current) return;
    const r = ref.current.getBoundingClientRect();
    if (r.top < window.innerHeight && r.bottom > 0) { setShown(true); return; }
    const obs = new IntersectionObserver(([e]) => {
      if (e.isIntersecting) { setShown(true); obs.disconnect(); }
    }, { threshold });
    obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);
  return [ref, shown];
}
```

包成 `<Reveal delay={150}>...</Reveal>` 使用。

---

# 變體建立模式（最重要的方法論）

每個案子做 **3–5 個 hero variant**，差別在「空間結構」不是「換顏色」。

## 已驗證的 hero 變體配方（直接套）

### D · 靜態主視覺
- 左：直書中文大字（writing-mode: vertical-rl）+ 副標 + CTA
- 右：靜態 SVG 圖形（kaleidoscope / 月曆 / 主題符號），scroll 帶動旋轉
- Label pointers 從圖形延伸到左側標籤
- 適合：定錨方向，所有其他 variant 的「基準版」

### E · 戲院 Cinematic（動態 + 深底）
- 全版面深底（`#0d0a07`），影片從右側半邊 bleed
- 左→右 linear-gradient 黑紗讓左側文字浮起
- 大字標題在左，CTA 橘紅實心 + 透明邊框雙按鈕
- 適合：希望被影片打動的「夜場」感

### F · 沉浸滿版 Immersive（動態 + 滿版）
- 影片 100vw 100vh full bleed
- 上下深漸層讓中央 typography 浮起
- 中央極簡：副標籤 / 大襯線標題 / 一行英文標籤 / 段落 / 雙 CTA
- 適合：影片素材夠強、希望像 Apple 產品頁的氣場

### G · 紙感放映 Paper Cinema（動態 + 紙底）
- 紙底，左文字 + 右 FrameStack 包影片
- 影片框略傾斜（rotate -1.5deg）
- 像翻雜誌彩頁，保留印刷感
- 適合：客戶很在乎「紙本」品牌 DNA，不想全黑

### A/B/C（VHS 系列備案，按需要再生）
- A · 錄放機（卡帶插入動畫）
- B · 12 卷帶子（月份卡帶橫向 pan）
- C · 編輯雜誌（極簡封面 + 彩框卡帶 portrait）

## 切換器 UI

右上 floating `<VersionSwitcher>` — 列出所有 variant + 一行說明，點下去帶 `?v=X` 跳轉。
務必加註「這個切換器只給設計提案使用，正式上線時會移除」讓客戶知道是內部工具。

---

# /showcase 對外比稿頁（必做）

這是 deliver 的入口。客戶 / 廠商收到的是 **`/showcase` 網址**，不是 `/`。

## 結構

```
§01 視覺方向 · COMPARE
  ↳ 4–5 張卡（2 欄 grid）
  ↳ 每張：iframe 預覽（scale 0.5 + pointerEvents none）+ 完整文字說明 + 「看完整版 ↗」
  ↳ 主推版本標 ★ 動態版 / ★ 主推 邊框 + boxShadow 強調

§02 GUIDE 怎麼挑
  ↳ 3 張比較卡：每個動態 variant「想呈現什麼？」+「適合：...」
  ↳ 結尾 callout 框：「選完之後我們會做什麼 — 把那個方向再深化（CIS 配色、字型細節、副本、下段視覺）」

§03 投稿頁 / 表單預覽（如果案子有）
  ↳ 大張 iframe + 「本階段範圍說明」框
  ↳ 寫清楚「送出鍵暫時不會寫入資料庫，二階才上後端」

§00 Header
  ↳ kicker 標籤 + 大字標題 + 客戶/執行/定錨/時程 4 欄 dl
```

## 注意事項

1. **`robots: { index: false, follow: false }`** — 不要被 Google 抓到
2. **iframe 預覽用 `scale(0.5)` + `pointerEvents: none`** — 讓畫面塞下又不被誤點
3. **隱藏內部進度** — 不在 showcase 露 admin 路由、Supabase 連接、後端工作。客戶不需要知道我們做了多少
4. **OG meta** — 標題 + 描述設好，讓 LINE / Slack 預覽好看
5. **路由名稱用 `/showcase`** 不要用 `/preview` 或 `/demo`，前者讓人覺得「比稿提案」，後者像「未完成」

## 範本路徑

完整實作見 `feature{N}_client_project/web/src/app/showcase/page.tsx` — 350+ 行可直接 fork。

---

# 技術棧（驗證過）

- **Next.js 16 App Router + Turbopack**（不是 13/14 — API 不同）
- **React 19**（`useSyncExternalStore` 解 SSR/client mismatch、URL 參數讀取）
- **TypeScript** strict
- **Tailwind v4** with `@theme inline` block in `globals.css`（不用 tailwind.config.ts）
- **`next/font`** — 字體必經這個拿 CSS 變數
- **Vercel** deploy（`vercel --prod --yes`）
- **Supabase SSR** 套件預裝但二階才用
- **影片 backdrop**：放 `/public/motion-hero.mp4`（≤ 5 MB）+ poster JPG fallback

---

# Variant routing 樣板（必複製）

```tsx
// src/components/.../App.tsx
"use client";
import { useEffect, useMemo, useState, useSyncExternalStore } from "react";

export type Variant = "d" | "e" | "f" | "g";

function readVariant(): Variant {
  if (typeof window === "undefined") return "d";
  const u = new URLSearchParams(window.location.search).get("v");
  return ["d","e","f","g"].includes(u || "") ? (u as Variant) : "d";
}

function subscribePopstate(notify: () => void) {
  window.addEventListener("popstate", notify);
  return () => window.removeEventListener("popstate", notify);
}

export function App() {
  // SSR-safe — 預設 D，client 端讀 URL
  const variant = useSyncExternalStore(subscribePopstate, readVariant, () => "d");
  useEffect(() => {
    document.documentElement.setAttribute("data-palette", "kaleido");
  }, []);
  const heroes = useMemo(() => ({ d: HeroD, e: HeroE, f: HeroF, g: HeroG }), []);
  const HeroComp = heroes[variant];
  return <div data-variant={variant}>...</div>;
}
```

⚠ **千萬不要** 把 variant 讀取放 `useState(() => readVariant())` 然後 `useEffect` 改 — 那會 hydration mismatch。
**用 `useSyncExternalStore`**。

---

# 部署 SOP

1. `npm run build` 必過 + ESLint 0 errors
2. `vercel --prod --yes` 部署（已用 GitHub OAuth 登入過 `noron1223s-projects`）
3. 部完 verify：`curl -s -o /dev/null -w "%{http_code}\n" <url>` 所有 variant 都 200
4. 用 grep 確認不該外洩的字眼沒進 HTML：`curl -s URL | grep -oE "admin|後台|password" | sort -u`
5. 更新 memory 對應 project 檔（部署網址、變體名、Stage 狀態）

---

# 反模式（看到就阻止）

- ❌ 用 Tailwind utility class 直接拼 hero（`bg-amber-50 text-stone-900`），會生出「AI 平庸 SaaS」感
- ❌ 把所有顏色寫死在 inline style — 一定要走 CSS variables `var(--accent)`，客戶要換配色才能一次切到底
- ❌ Hero 只放 emoji 或 stock icon — 一定要自製 SVG 圖形（kaleidoscope / cassette / 月曆 etc.）
- ❌ 一個 variant 一個 codebase — 全部塞同個 Next.js 用 `?v=` 切
- ❌ /showcase 露後端 / admin / 內部工具 — 客戶只看設計成果，不知道我們做了多少
- ❌ 全 client component — Server component 能 static prerender 的就 static
- ❌ `useState(() => window.x)` lazy init — SSR 會 mismatch，用 `useSyncExternalStore`

---

# Starter kit · 可直接 fork 的元件

`~/.claude/skills/design-pitch-site/snippets/` 內已有：

| 檔 | 用途 |
|---|---|
| `globals.css` | 5 套 palette CSS 變數 + 紙感網點 + reveal/spin/recPulse/float keyframes |
| `layout.tsx` | Next.js root layout，4 套 next/font 字體串好 |
| `Kaleido.tsx` | Kaleidoscope 12 切片 SVG + 6 紋理 pattern + LabelPointer |
| `Vhs.tsx` | Cassette + FrameStack + GeoNumber + VHSDeck |
| `hooks.tsx` | useReveal + Reveal wrapper + useScrollProgress + useCountdown（含 useSyncExternalStore SSR-safe pattern） |
| `Switchers.tsx` | 右上 VersionSwitcher + 底部 StageBar 浮動切換器 |
| `showcase-page.tsx` | 對外比稿頁完整範本（350+ 行） |

下次跑這個 skill 第一步：把 snippets 整個 `cp` 進新專案 `src/components/<name>/` 與 `src/app/`，再依新 brief 改 hero。

---

# 案例庫

| 案子 | URL | 美術方向 | 變體數 |
|---|---|---|---|
| 協作徵稿平台（project-a） | https://your-project.vercel.app/showcase | 萬花筒 + 紙感 + 動態（kaleido palette） | 4（D/E/F/G） |

下次跑這個 skill 時把新案子加進案例庫，並 fork 上一個的 Sections.tsx / Kaleido.tsx 起頭，再依新 brief 改 hero。
