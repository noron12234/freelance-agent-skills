// 批次截圖：1440x900 桌面 viewport、prod 環境
import { chromium } from "playwright";

const BASE = "https://your-project.vercel.app";
const ADMIN_PW = "cal2027-admin";
const OUT_DIR = "/Users/linjunrong/Desktop/test/waiting-list/manual";

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SUPABASE_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

async function fetchSample() {
  // 找一筆 approved + address_token 的稿件作為詳情頁示範
  const r = await fetch(
    `${SUPABASE_URL}/rest/v1/submissions?status=eq.approved&address_token=not.is.null&limit=1&select=id,address_token`,
    { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${SUPABASE_KEY}` } },
  );
  const data = await r.json();
  return data[0];
}

async function fetchReviewing() {
  const r = await fetch(
    `${SUPABASE_URL}/rest/v1/submissions?status=eq.reviewing&limit=1&select=id`,
    { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${SUPABASE_KEY}` } },
  );
  const data = await r.json();
  return data[0];
}

const sample = await fetchSample();
const reviewing = await fetchReviewing();

const browser = await chromium.launch({ headless: true });
const ctx = await browser.newContext({
  viewport: { width: 1440, height: 900 },
  deviceScaleFactor: 2, // retina = 較好印刷品質
  locale: "zh-TW",
});
const page = await ctx.newPage();

async function shot(path, opts = {}) {
  if (opts.delay) await new Promise(r => setTimeout(r, opts.delay));
  await page.screenshot({
    path: `${OUT_DIR}/${path}`,
    type: "png",
    fullPage: opts.fullPage || false,
    clip: opts.clip,
  });
  console.log(`✓ ${path}`);
}

// ──────── 前台 ────────
console.log("→ 前台...");
await page.goto(`${BASE}/`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1500));
await shot("01_homepage_hero.png");

// 滾到 SurveyBanner（投稿引導）
await page.evaluate(() => {
  const el = document.getElementById("submit-banner");
  if (el) el.scrollIntoView({ behavior: "instant", block: "center" });
});
await new Promise(r => setTimeout(r, 800));
await shot("01b_homepage_cta.png");

// 投稿表單三段
await page.goto(`${BASE}/submit`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1000));
await page.evaluate(() => window.scrollTo({ top: 0, behavior: "instant" }));
await shot("02_submit_step1_date.png");

await page.evaluate(() => window.scrollTo({ top: 700, behavior: "instant" }));
await new Promise(r => setTimeout(r, 400));
await shot("03_submit_step2_story.png");

await page.evaluate(() => window.scrollTo({ top: 1500, behavior: "instant" }));
await new Promise(r => setTimeout(r, 400));
await shot("04_submit_step3_upload.png");

await page.evaluate(() => window.scrollTo({ top: 2200, behavior: "instant" }));
await new Promise(r => setTimeout(r, 400));
await shot("05_submit_consent.png");

// thank-you
await page.goto(`${BASE}/thank-you`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1000));
await shot("06_thank_you.png");

// ──────── 登入後台 ────────
console.log("→ 登入後台...");
await page.goto(`${BASE}/admin/login`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 800));
await shot("08_admin_login.png");

await page.evaluate(async (pw) => {
  await fetch("/api/admin/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ password: pw }),
  });
}, ADMIN_PW);

// ──────── 後台 ────────
console.log("→ 收件匣...");
await page.goto(`${BASE}/admin`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1500));
await shot("09_admin_inbox.png");

console.log("→ 稿件詳情...");
if (sample) {
  await page.goto(`${BASE}/admin/${sample.id}`, { waitUntil: "domcontentloaded" });
  await new Promise(r => setTimeout(r, 1500));
  await shot("10_admin_detail.png");
}

console.log("→ 撞期裁決...");
await page.goto(`${BASE}/admin/duplicate`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1200));
await shot("11_admin_duplicate.png");

console.log("→ 365 日曆...");
await page.goto(`${BASE}/admin/calendar`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1500));
await shot("12_admin_calendar.png");

console.log("→ 排程刊登...");
await page.goto(`${BASE}/admin/scheduled`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1200));
await shot("13_admin_scheduled.png");

console.log("→ 製稿匯出...");
await page.goto(`${BASE}/admin/export`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1200));
await shot("14_admin_export.png");

console.log("→ Email 模板...");
await page.goto(`${BASE}/admin/flow`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1500));
await shot("15_admin_flow.png");

await page.goto(`${BASE}/admin/flow?tmpl=approved&mode=edit`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1800));
await shot("16_admin_flow_edit.png");

console.log("→ 發信紀錄...");
await page.goto(`${BASE}/admin/email-logs`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1200));
await shot("17_admin_email_logs.png");

console.log("→ 出貨管理...");
await page.goto(`${BASE}/admin/shipping`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1200));
await shot("18_admin_shipping.png");

console.log("→ 網站設定...");
await page.goto(`${BASE}/admin/settings`, { waitUntil: "domcontentloaded" });
await new Promise(r => setTimeout(r, 1500));
await shot("19_admin_settings.png");

console.log("→ 地址填寫頁...");
if (sample?.address_token) {
  await page.goto(`${BASE}/address/${sample.address_token}`, { waitUntil: "domcontentloaded" });
  await new Promise(r => setTimeout(r, 1200));
  await shot("20_address_form.png");
}

// 觸發 modal 截圖
console.log("→ 寄信預覽 Modal...");
if (reviewing) {
  await page.goto(`${BASE}/admin/${reviewing.id}`, { waitUntil: "domcontentloaded" });
  await new Promise(r => setTimeout(r, 1500));
  // 點「已過稿」按鈕
  await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll("button"));
    const b = btns.find(x => x.innerText.trim() === "已過稿");
    if (b) b.click();
  });
  await new Promise(r => setTimeout(r, 3500));
  await shot("21_mail_preview_modal.png");
  // 取消、還原狀態
  await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll("button"));
    const c = btns.find(x => x.innerText.trim() === "取消");
    if (c) c.click();
  });
  // 改回 reviewing
  await fetch(
    `${SUPABASE_URL}/rest/v1/submissions?id=eq.${reviewing.id}`,
    {
      method: "PATCH",
      headers: {
        apikey: SUPABASE_KEY,
        Authorization: `Bearer ${SUPABASE_KEY}`,
        "Content-Type": "application/json",
        Prefer: "return=minimal",
      },
      body: JSON.stringify({ status: "reviewing", admin_note: null }),
    },
  );
}

await ctx.close();
await browser.close();
console.log("✓ 全部完成");
