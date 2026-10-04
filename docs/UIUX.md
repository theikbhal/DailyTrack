# DailyTrack — UI/UX Design

## Who this is for

| Trait | Design consequence |
|---|---|
| ADHD, 40, serial entrepreneur | One default screen. Nothing auto-opens except Today. No onboarding longer than 4 taps. |
| Huge intentions, broken consistency | 75% kept-line, never perfection. Copy never shames. |
| Small town, family, father | Life trackers (Ismail bhai call, madrasa, Sunday) sit beside worship — not in a separate "productivity" silo. |
| Ex-software engineer | Numbers everywhere: percentages, XP, HP, streaks. Progress is legible as data. |
| Ex-failures, still starting | "Restart the day" language; enemies take damage from a single completed tracker. |

## Information architecture

```
Today      ← default, the only required screen
Calendar   ← evidence (day/week/month/year heatmap)
Progress   ← streaks · levels · badges · enemies · 14-day bars
Encourage  ← when willpower is empty
Help       ← docs + roadmap, in-app
Settings   ← experiments · notifications · appearance · data · sync · about
```

Sidebar list, not a toolbar — 6 items, keyboard ⌘1–⌘6, level badge pinned to the sidebar floor so XP is ambient.

## Visual system

| Token | Value |
|---|---|
| Corner radius | 14 pt cards, 10 pt tiles, Capsule for pills |
| Card surface | `.ultraThinMaterial` — adapts to dark mode for free |
| Accent | per-theme; default System (macOS accent) |
| Type | SF rounded for numbers (counts, XP, HP), system elsewhere |
| Progress | ring for the day score, horizontal bars for trackers and XP |
| Color semantics | green = kept/done · orange = in progress · purple = streak · yellow = coins · red = enemies |

## Themes (Settings → Appearance)

System · Light · **Dark** · Ocean · Forest · Sunset · Royal · Minimal — applied via `.preferredColorScheme` + `.tint` at the root so every surface, material and chart follows.

## The abacus

5 rods (1s → 10000s), 1 heaven bead (5) + 4 earth beads (1) per rod, gold beam.
Inactive beads are grey and rest away from the beam; active beads take the theme gradient and hug the beam — **state is readable at a glance, not by counting**.
Tap heaven = ±5·place, tap earth bead j = set the unit digit to j or j+1. Numeric readout always sits beside it; the abacus is an accelerator, never the only input.

## Motion

- Beads: spring 0.25 s (physical, not decorative)
- Bars/rings: spring 0.4 s
- Confetti: 1.4 s burst, only on completion and only if the `confetti` flag is on
- Toast banner: slide from top, auto-dismiss 2.4 s
- No ambient animation — idle cost is zero.

## Copy voice

Direct, second person, zero guilt, occasional Arabic affirmation:

- "Day kept" / "In progress" (never "failed")
- "MashaAllah — your minimum is secured. Everything above is reward."
- "A missed day lets them heal." (enemies, not you)
- "Small and consistent beats big and rare."

## Accessibility

- Every color state is paired with a number or label (score %, HP text, "Done")
- Minimum 11 pt for data labels, 14 pt for body
- All controls are native macOS (`Toggle`, `Button`, `Stepper`, `Picker`) → VoiceOver and keyboard for free
- Forced dark/light modes honor the user's explicit choice over the system

## Anti-patterns deliberately avoided

- No infinite scroll, no feed, no tabs inside tabs
- No modal that blocks Today except first-run onboarding
- No red "you missed this" state — orange "open"
- No cloud login wall
