---
name: case-folder-template
description: 次元創意接案標準資料夾結構 v2 — 6 個固定資料夾、簽約後新案啟動就用這個。沉澱自 2026-06-08 協作徵稿平台 案整理。v3 (2026-06-15)：加上「客戶系統上線前必跑備份 setup 4 步」SOP，沉澱自協作徵稿平台 backup 重災演習。
---

# case-folder-template

新案啟動時、建立次元創意標準資料夾結構。

## 何時觸發

- 用戶說「新案啟動」「建案件資料夾」「案件結構」
- /case-init 之後接這個（取代 case-init 原本的 6-9 層預設）
- 重整現有案件時參考

## 標準結構（6 個資料夾）

```
<案件名>/
├── 00_客戶端/                   ← 跟客戶有關的全部
│   ├── 客戶提供素材/             ← 他們給我們的（CIS、字體、需求 PDF 等）
│   ├── 客戶往來訊息/             ← LINE / Email 對話記錄
│   ├── 使用說明書/              ← 給客戶看的使用說明 PDF（如有）
│   └── 系統演示影片/            ← 給客戶看的演示 mp4（如有）
├── 01_需求書/                  ← 我方寫的需求書版本（v1-vN）
├── 02_合約/                    ← 軟體開發合約最終版
├── 03_會議/                    ← 內部會議資料（不對外）
├── 04_工程師外包/              ← 工程師端資料
│   ├── 交接包/                  ← 技術交接文件
│   └── 外包合約/                ← 委外合約
├── 05_設計提案/                ← 早期視覺探索（wireframe / mood board / styleA / styleB）
└── web/  或  app/  或  ...     ← 程式碼（看技術棧）
```

## 設計原則

| 原則 | 為什麼 |
|---|---|
| **不放「提案 / 報價」資料夾** | 簽約後不需要、會混淆 |
| **客戶端統一放 00_** | 給客戶交付的東西集中、不會誤傳內部檔 |
| **工程師端統一放 04_** | 對工程師的文件（交接、外包合約）合併 |
| **編號連續 00-05** | 不要跳號（避免「03 跑哪去了？」這種困惑）|
| **不放使用說明書工具箱** | 用 `gen-manual-pdf` skill 統一管理、不放案件內 |

## 從舊結構遷移

舊案如果是「00_客戶提供 / 02_提案報價 / 05_工程師交接 / 06_外包合約 / 07_設計提案 / 08_客戶往來」這種 v1 結構、要遷移：

```bash
cd <案件根目錄>
# 1. 備份
cp -R . ../_backup_整理前_$(date +%Y%m%d)

# 2. 合併客戶端
mkdir -p 00_客戶端/客戶提供素材 00_客戶端/客戶往來訊息
mv 00_客戶提供/* 00_客戶端/客戶提供素材/ && rmdir 00_客戶提供
mv 08_客戶往來/* 00_客戶端/客戶往來訊息/ && rmdir 08_客戶往來

# 3. 砍提案報價
rm -rf 02_提案報價

# 4. 合併工程師
mkdir -p 04_工程師外包/交接包 04_工程師外包/外包合約
mv 05_工程師交接/* 04_工程師外包/交接包/ && rmdir 05_工程師交接
mv 06_外包合約/* 04_工程師外包/外包合約/ && rmdir 06_外包合約

# 5. 重排編號
mv 03_合約 02_合約
mv 04_會議 03_會議
mv 07_設計提案 05_設計提案
```

## 寫 README.md

建好資料夾後、根目錄一定要放 `README.md` 講：
- 客戶是誰
- 線上版 URL
- 後台密碼
- 重新部署指令
- 每個資料夾放什麼
- 「給客戶 X」要去 `00_客戶端/X/`

範本參照：協作徵稿平台案 `feature{N}_client_project/README.md`

## 跟其他 skill 的關係

- `/case-init` — 一鍵新案啟動（建議改用本 skill 的 6 資料夾結構、不要用 case-init 預設的 6-9 層）
- `gen-manual-pdf` — 產出 PDF 給客戶、產出後副本放 `00_客戶端/使用說明書/`
- `meeting-to-pm-spec` — 會議錄影 → PM 規劃書、產出放 `03_會議/<日期>_<主題>/`
- `proposal-iteration` — 簽約前的提案 / 需求書迭代、簽約後存到 `01_需求書/` + `02_合約/`

## ⚠️ 上線前必跑備份 setup（沉澱自協作徵稿平台案、2026-06-15）

**鐵則：客戶系統上線前一定要設好自動備份，不要事後補。**

新案有 prod 資料（Supabase / Insforge / Fly / 任何 DB / Storage）就跑這 4 步：

### Day 1 — Code 還沒上線就要做
- ☐ 建第二個 DB project 當 staging（同平台 free tier 多開一個）
- ☐ 開兩個 DB client（anon + service_role 拆分）
- ☐ 全表 RLS 開、寫 policy（anon 只給「必要的公開操作」）

### Day 2 — 寫 backup 比寫 feature 早
- ☐ 從 `~/Desktop/test/waiting-list/.github/workflows/backup-calendar-*.yml` 拷貝模板改一份新 workflow
- ☐ 從 `~/Desktop/test/waiting-list/.github/actions/b2-upload/` + `gdrive-upload/` 用既有 composite action
- ☐ 在 B2 bucket `noron12334-waitinglist-backups-2026` 多開一個 prefix（不用新 bucket，用路徑分）
- ☐ Google Drive `gdrive:_waitinglist_backups/` 同樣加 prefix
- ☐ secrets `gh secret set XXX_SERVICE_ROLE_KEY ...`
- ☐ 從 `~/Desktop/test/waiting-list/tools/restore/restore-*.sh` 拷貝模板改 3 個 restore script
- ☐ 手動觸發 baseline backup 驗證 3 層（GitHub / B2 / GDrive）都成功

### Day 3 — 上線前 dogfood
- ☐ 跑一次 restore drill 到 staging DB
- ☐ 抽 5 筆 spot check
- ☐ 合約寫進「資料每日 6h backup + 三層 off-site」當賣點

### Month 1+ — 月度演習
- ☐ 月初開 GitHub Actions 確認 backup 條條全綠
- ☐ 看 `STATS.csv` row 趨勢有沒有異常掉

**已知 anti-pattern（不要做）：**
- 「上線後再補備份」→ 上線到補備份中間掉資料就完蛋
- 「只開一層備份」→ GitHub 帳號被駭就全沒
- 「admin route 用 anon key」→ RLS 開了等於沒開
- 「備份不驗證」→ 沒驗過 = 沒備份

**完整 SOP 跟還原 script 參考：**
協作徵稿平台 repo `~/Desktop/test/waiting-list/AGENT_BACKUP_GUIDE.md` + `BACKUP_RECOVERY.md`

## 反例

❌ 之前的舊結構（協作徵稿平台 v1）：
```
00_客戶提供 / 01_需求書 / 02_提案報價 / 03_合約 / 04_會議 /
05_工程師交接 / 06_外包合約 / 07_設計提案 / 08_客戶往來 + manual/（放案件外）
```
問題：
- 客戶相關東西分散在 00 跟 08
- 工程師相關分散在 05 跟 06
- 「提案報價」簽約後沒用
- manual/ 放案件外、其他人找不到
- 編號跳號（02 / 06 不在）

✅ v2 統一結構：6 個資料夾、客戶端 / 工程師端 各自合併、編號連續、工具箱獨立成 skill。
