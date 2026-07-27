**English** · [繁體中文](README.zh-TW.md)

# Freelance Agent Skills

A set of 11 [Claude Code](https://claude.com/claude-code) skills that automate the parts of solo software consulting that aren't writing code — proposals, client revisions, launch monitoring, documentation, and analytics.

Extracted from ~2 years of running client projects solo. Every skill here was written because I did the same thing manually three times and got tired of it.

---

## Why this exists

A solo developer running client projects spends maybe 40% of their time writing code. The other 60% is proposal documents, translating meeting recordings into specs, applying client revisions, writing manuals, wiring analytics, and watching production after launch.

That 60% is repetitive, high-context, and exactly what an agent is good at — but only if you encode the workflow, not just the intent. These skills are that encoding.

## Architecture

The skills map to the lifecycle of a client engagement:

```
  DISCOVERY          BUILD              LAUNCH            MAINTAIN
  ─────────          ─────              ──────            ────────
  meeting-to-pm-spec                    integrate-        autonomous-
        │            design-pitch-site  posthog-tracking  polish-loop
        ▼                  │                  │                │
  proposal-iteration       │            gen-manual-pdf   apply-client-
        │            gen-ai-hero-video        │          doc-changes
        ▼                  │                  │                │
  case-folder-template     └──────────────────┴────────────────┘
        │                                     │
        └──────────── case-sync ──────────────┘
                  (progress tracking, all phases)

  copy-competitor-workspace  ─ research, any phase
```

## The skills

### Discovery → Proposal

| Skill | What it does |
|---|---|
| **`meeting-to-pm-spec`** | Google Drive link or local audio → Whisper transcript → structured spec. Two modes: *handoff* (P0/P1/P2 engineer checklist) or *outline* (agenda + decisions + action items). Auto-creates the project folder. |
| **`proposal-iteration`** | The full proposal/quote/contract iteration SOP — dual-track versioning (internal `v1.x`, client-facing unversioned), A/B/C price anchoring, CTA design, an 11-item forbidden-phrase list for client-facing tone, and three classes of PDF QA (overflow, orphan pages, hardcoded page numbers). The largest skill here at ~2,800 lines. |
| **`case-folder-template`** | Standard 4-level project folder scaffold, plus the pre-launch backup checklist. |

### Build

| Skill | What it does |
|---|---|
| **`design-pitch-site`** | Ships one Next.js codebase serving several visual variants (`?v=d/e/f/g`) plus a `/showcase` comparison page, so the client picks a direction instead of describing one. Includes a warm editorial design system. |
| **`gen-ai-hero-video`** | Platform selection matrix (Kling / Runway / Luma / Hailuo) for image-to-video hero sections, prompt templates for 6 common hero types, and the Next.js `<video>` + mobile fallback pattern. |
| **`copy-competitor-workspace`** | Methodology for tearing down a competitor's *logged-in* product (landing pages don't tell you anything) across four axes, then ranking what's worth copying by ROI. |

### Launch

| Skill | What it does |
|---|---|
| **`integrate-posthog-tracking`** | One-shot PostHog install for a Next.js project — session replay, funnels, error tracking, MCP wiring. ~5 minutes to ready. |
| **`gen-manual-pdf`** | Generates a client-facing system manual as a multi-chapter A4 PDF — Playwright screenshot capture, editorial layout, FAQ section. |

### Maintain

| Skill | What it does |
|---|---|
| **`autonomous-polish-loop`** | Dual-cron post-launch loop: one watches for bugs, one hunts UX papercuts. Fixes get queued for human approval rather than auto-shipped to production. |
| **`apply-client-doc-changes`** | Client sends a Word/Google Doc with yellow highlights and strikethroughs → parse with `python-docx` → locate the corresponding strings in source → batch edit → commit. Turns a 90-minute copy-paste job into a reviewable diff. |
| **`case-sync`** | Watches the conversation for project status changes (contract signed, deposit received, phase advanced) and writes them to a project dashboard, so nobody has to be the PM. |

---

## Install

Skills live in `~/.claude/skills/`. Clone and symlink whichever ones you want:

```bash
git clone https://github.com/noron12234/freelance-agent-skills.git
cd freelance-agent-skills

# all of them
ln -s "$PWD"/skills/* ~/.claude/skills/

# or just one
ln -s "$PWD/skills/proposal-iteration" ~/.claude/skills/
```

Then invoke by name in Claude Code:

```
/proposal-iteration
/meeting-to-pm-spec
```

Some skills need extra tooling — `meeting-to-pm-spec` wants `whisper.cpp` and `rclone`, `gen-manual-pdf` and `design-pitch-site` want Playwright. Each `SKILL.md` lists its own prerequisites.

## Conventions

Every skill follows the same shape:

- **`SKILL.md`** — frontmatter (`name`, `description` with trigger phrases) then the procedure
- **Trigger phrases in the description** — how the agent decides the skill applies
- **Templates and snippets in subdirectories** — kept out of the main procedure so it stays readable
- **A "learned from" note** — which real engagement the skill was extracted from, and what it cost in time before it was automated

## A note on the examples

All client names, URLs, and identifying details have been replaced with placeholders (`客戶A`, `your-project.vercel.app`, `example.com`). Screenshots and delivered artifacts from real engagements have been removed entirely. What's left is the methodology, which is mine; the client work is not.

## License

MIT — see [LICENSE](LICENSE).

Documentation is bilingual (Traditional Chinese procedures, English structure), reflecting how they're actually used.
