[English](README.md) · **繁體中文**

# Freelance Agent Skills

11 個 [Claude Code](https://claude.com/claude-code) skill，把個人接案裡「不是在寫程式」的那些事自動化 —— 提案書、客戶改稿、上線後監控、使用說明書、數據埋碼。

沉澱自約兩年一個人跑客戶專案的實戰。每一個 skill 的誕生原因都一樣：同一件事我手動做了三次，做到不想再做。

---

## 為什麼會有這個東西

一個人接案的開發者，大概只有 40% 的時間在寫程式。剩下 60% 是：寫提案書、把會議錄音變成規格、套用客戶的改稿、寫使用說明書、接數據工具、上線後盯著它別出事。

那 60% 重複、吃脈絡，而且正好是 agent 擅長的 —— 但前提是你要把**工作流**編碼下來，不是只給它一句「幫我寫提案書」。這些 skill 就是那個編碼。

## 架構

Skill 對應接案的生命週期：

```
  探索期              建置期              上線期            維運期
  ─────              ─────              ─────            ─────
  meeting-to-pm-spec                    integrate-        autonomous-
        │            design-pitch-site  posthog-tracking  polish-loop
        ▼                  │                  │                │
  proposal-iteration       │            gen-manual-pdf   apply-client-
        │            gen-ai-hero-video        │          doc-changes
        ▼                  │                  │                │
  case-folder-template     └──────────────────┴────────────────┘
        │                                     │
        └──────────── case-sync ──────────────┘
                    （進度追蹤，貫穿全期）

  copy-competitor-workspace ─ 調研，任何階段
```

## Skill 清單

### 探索 → 提案

| Skill | 做什麼 |
|---|---|
| **`meeting-to-pm-spec`** | Google Drive 連結或本機音檔 → Whisper 逐字稿 → 結構化規格書。兩種模式：*handoff*（給工程師的 P0/P1/P2 清單）或 *outline*（會議大綱 + 決議 + 待辦）。新專案自動建資料夾。 |
| **`proposal-iteration`** | 提案書／報價／合約的完整迭代 SOP —— 雙軌版本管理（內部 `v1.x`、對外無版號）、A/B/C 價格錨定、CTA 設計、對外語氣的 11 個必清字眼、以及 PDF 的三類 QA（溢位／孤兒頁／寫死頁碼）。約 2,800 行，本專案最大的一個。 |
| **`case-folder-template`** | 標準四層專案資料夾結構，含上線前備份檢查清單。 |

### 建置

| Skill | 做什麼 |
|---|---|
| **`design-pitch-site`** | 一份 Next.js codebase 同時跑多個視覺 variant（`?v=d/e/f/g`）＋ 一頁 `/showcase` 比稿頁，讓客戶用「選」的而不是用「形容」的。內含暖色 editorial 設計系統。 |
| **`gen-ai-hero-video`** | Hero 主視覺做 image-to-video 的平台選型對照（Kling / Runway / Luma / Hailuo）、6 種常見 hero 類型的 prompt 範本、以及 Next.js `<video>` + mobile fallback 的接法。 |
| **`copy-competitor-workspace`** | 拆解競品**登入後**產品的方法論（landing page 什麼都看不出來），分四個維度拆完後按投報比排出可抄清單。 |

### 上線

| Skill | 做什麼 |
|---|---|
| **`integrate-posthog-tracking`** | Next.js 專案一次裝好 PostHog —— session replay、漏斗、error tracking、MCP 串接。約 5 分鐘完成。 |
| **`gen-manual-pdf`** | 產出給客戶看的系統使用說明書，A4 多章節 PDF —— Playwright 截圖、editorial 排版、FAQ 章節。 |

### 維運

| Skill | 做什麼 |
|---|---|
| **`autonomous-polish-loop`** | 上線後的雙 cron 迴圈：一條盯 bug、一條找 UX 毛邊。修好的東西進待審佇列等人確認，不會自動推上 production。 |
| **`apply-client-doc-changes`** | 客戶傳來標了黃字和刪除線的 Word／Google Doc → 用 `python-docx` 解析 → 對應到原始碼位置 → 批次修改 → commit。把 90 分鐘的複製貼上變成一份可 review 的 diff。 |
| **`case-sync`** | 從對話中偵測專案狀態變化（合約簽了、訂金到帳、階段推進），自動寫進案件儀表板，這樣就沒人需要當 PM。 |

---

## 安裝

Skill 放在 `~/.claude/skills/`。clone 下來後把要用的建立軟連結：

```bash
git clone https://github.com/noron12234/freelance-agent-skills.git
cd freelance-agent-skills

# 全部
ln -s "$PWD"/skills/* ~/.claude/skills/

# 或只要其中一個
ln -s "$PWD/skills/proposal-iteration" ~/.claude/skills/
```

然後在 Claude Code 裡用名字呼叫：

```
/proposal-iteration
/meeting-to-pm-spec
```

有些 skill 需要額外工具 —— `meeting-to-pm-spec` 需要 `whisper.cpp` 和 `rclone`，`gen-manual-pdf` 和 `design-pitch-site` 需要 Playwright。每個 `SKILL.md` 裡都寫了自己的前置需求。

## 撰寫慣例

每個 skill 的結構都一樣：

- **`SKILL.md`** —— frontmatter（`name`、含觸發詞的 `description`），接著是流程本體
- **description 裡放觸發詞** —— agent 靠這個判斷這個 skill 該不該用
- **範本和 snippet 放子目錄** —— 從主流程抽出來，讓流程本身保持好讀
- **一句「沉澱自哪裡」** —— 這個 skill 是從哪個真實案子萃取出來的，以及自動化之前它花掉多少時間

## 關於範例

所有客戶名稱、網址、可識別資訊都已替換成代號（`客戶A`、`your-project.vercel.app`、`example.com`）。真實案子的截圖和交付檔案已全數移除。留下的是方法論，那是我的；客戶的東西不是。

## 授權

MIT —— 見 [LICENSE](LICENSE)。
