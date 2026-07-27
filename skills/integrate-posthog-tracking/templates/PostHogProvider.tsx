"use client";

// PostHog · session replay + autocapture + error tracking + performance
// 5,000 session/月免費、自動 mask input、自動捕捉 click/pageview/scroll/error
// 沉澱自協作徵稿平台（2026-06-16）、跨案可抄
import { useEffect } from "react";
import { usePathname, useSearchParams } from "next/navigation";
import posthog from "posthog-js";

const KEY = process.env.NEXT_PUBLIC_POSTHOG_KEY;
const HOST = process.env.NEXT_PUBLIC_POSTHOG_HOST ?? "https://us.i.posthog.com";

let inited = false;

export function PostHogProvider({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const searchParams = useSearchParams();

  useEffect(() => {
    if (!KEY || inited) return;
    posthog.init(KEY, {
      api_host: HOST,
      capture_pageview: false, // 手動 capture（router 變動才 fire、避免 SSR/CSR 重複）
      capture_pageleave: true,
      autocapture: true, // 自動捕捉 click / form submit / input change
      capture_exceptions: true, // 自動抓 JS error / unhandled promise reject
      capture_performance: true, // 自動抓 LCP / CLS / TTFB（mobile 真實速度）
      session_recording: {
        maskAllInputs: true, // input/textarea 內容 mask 成 ●●● — PII 安全
        maskTextSelector: "[data-mask]", // 額外加 data-mask 屬性也會 mask
      },
      persistence: "localStorage+cookie",
      loaded: (ph) => {
        if (process.env.NODE_ENV === "development") ph.debug();
      },
    });
    inited = true;
  }, []);

  useEffect(() => {
    if (!KEY || !inited) return;
    const url = pathname + (searchParams.toString() ? `?${searchParams}` : "");
    posthog.capture("$pageview", { $current_url: url });
  }, [pathname, searchParams]);

  return <>{children}</>;
}
