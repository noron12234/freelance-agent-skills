# Mapping Template — doc 段落 → source code 位置

開始改 code 前，先填這張表給用戶 review，避免動完才被打回票。

## 範本（複製改）

```
| # | 區塊 | doc 段落 ref | source code 位置 | 動作類型 | 詳細 |
|---|---|---|---|---|---|
| 01 | Hero | ★[14, 21, 28] | Sections.tsx HeroG line 855-1337 | 文字替換 | VOL.02 卷期 / Hero 內文 / CTA 文案 |
| 02 | 關於 | ★[34-47] | Sections.tsx KaleidoConcept 1338-1530 | 文字 + 結構 | eyebrow `DAYS WE MADE TOGETHER` / 加 1 stats row（投稿者橫跨）/ 加升級禮盒小註 |
| 03 | 投稿好處 | ★[53-69], ✂[62-64] | Sections.tsx BenefitsSection 3574- | 結構 + 文字 | 卡片 03 砍掉、卡片 04 補位、加底部小註 |
| 04 | 投稿頁 | ★[78-122], ✂[78, 88] | SubmitForm.tsx 全檔 | 多項 | 副標刪 / 日期區補充 / tag 14 個 / 照片建議 / 地址欄 / 同意 x2 / 錄取退稿原因 / 審稿時程 |
| 05 | 法律 | ✂[128-148] 整段 | submit/page.tsx | 整段刪 | LegalSection import 拿掉、layout 不 render |
| 06 | 故事示範 | ★[156] eyebrow | Sections.tsx KaleidoFeatured 1629- | 文字 | eyebrow 改新版「此為去年錄取的故事，六個故事示意」 |
| 07 | 產品介紹 | ★[392-405], ✂[392-393, 400-402] | Sections.tsx ProductSection 3108- | 文字 + 結構 | 主標換新版 / 賣點 03 砍舊 / 加新版賣點 |
| 08 | 期程 | ✂[430-431], ★[439] | Sections.tsx TimelineSection 3661- | 文字 + 結構 | 砍 2026.10 節點 / 加底部小註 |
```

## 動作類型 4 種

| 類型 | 動作 | 風險 |
|---|---|---|
| **文字替換** | 字串 → 字串 | 低 |
| **結構** | 增 / 減 / 重排 list 項目 | 中 |
| **整段刪** | 從 layout / component 拿掉 | 中（可能影響上下游） |
| **多項** | 表單欄位、state、validation | 高（要動 logic） |

## 給用戶的 message 範本

```
🔍 docx 解析完畢：
- {N} 處黃字（新增/修改）
- {M} 處刪除線
- 嵌入圖 {K} 張{備註：若 0 張就問圖在哪}

📋 對應 source code 的 {區塊數} 個區塊改動如下：

{對應表}

⏸ 跳過項目（待確認）：
- {不確定的 / 需要圖檔的 / 牽涉外部資源的}

確認 scope 後我開始動。
```

## 用戶確認後動手的順序

1. 安全的 → 危險的（文字 → 結構 → 刪段）
2. 自己跑 → 影響他人 → 可逆 → 不可逆（先動 code、再 commit、再 deploy）
3. 每改完一個區塊就 `curl localhost:3007/page` 驗證沒 build error
4. 不要 batch 改完才驗、會 debug 到爆

## Commit message 範本

```
feat(<project>): 套用 <客戶> <date> doc 全網站文案

doc strikethrough 拿掉：
- <列出 bullet>

doc 黃字新增/修改：
- <列出 bullet>

{若有同期其他改動}
其他：
- <列出>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```
