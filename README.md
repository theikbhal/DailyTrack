# DailyTrack

Single-user daily tracker for **zikir, namaz, rest and life** — built for one 40-year-old serial entrepreneur with ADHD, small-town life, a family to lead and a software engineer's brain that starts more than it finishes.

Local first. No account. No cloud required. One screen, only the trackers you switch on.

## The minimum

| Category | Trackers |
|---|---|
| Zikir | Darood **1100** · Astaghfar **1100** · Teen Tasbih **99** (33×3) |
| Namaz | 20 Rakat Nafil · Chash · Ishraq · Zuhr Sunnat Ghairullah (4 rakat, 30 min kept free) · 5 daily prayers |
| Rest | Night sleep **4–5 h** · Morning sleep **4 h** |
| Life | Sunday holiday extra time · Talk to Ismail bhai (dryfruits) daily · Visit madrasa 1–2×/week |

A day is **kept at 75% average** across your enabled daily trackers — not 100%, because perfection is what breaks the streak.

## Features

- **Abacus counter** — tap beads to set digits for darood / astaghfar / teen tasbih, or use +1/+10/+100
- **Experiments flags** — every tracker and every feature is a toggle in Settings → Experiments
- **Calendar** — day, week, month and year views with a kept-day heatmap
- **Streaks** — current, longest, total days kept
- **Levels** — 8 levels (Newcomer → Legend) driven by XP
- **Badges** — 16, from "Darood 1100" to "Boss Down"
- **Coins & energy** — earn with wins, 30 coins buy an energy refill, energy regenerates every 30 min
- **Enemies** — Laziness and Weak Health take damage when you complete trackers and heal when you miss a day
- **Daily push notifications** — morning 6:00, midday 13:30, evening 20:00 (all editable, all killable)
- **Encourage tab** — rotating motivation lines + a "Push through" boost
- **Export / import** JSON and CSV to your Desktop
- **Dark mode** and 7 more themes
- **Onboarding** and an in-app **Help + Roadmap**

## Install

```bash
cd mac
./scripts/build_app.sh          # build + /Applications + Desktop shortcut + AppTracker
open /Applications/DailyTrack.app
```

Other commands:

```bash
./scripts/build_app.sh --build-only   # build/ only
swift run DailyTrack --selftest       # 30 assertions, exit 0/1
swift run DailyTrack --plan           # print the notification plan
```

Keyboard: ⌘1 Today · ⌘2 Calendar · ⌘3 Progress · ⌘4 Encourage · ⌘5 Help · ⌘6 Settings · ⇧⌘O reset onboarding · ⇧⌘T test notification

## Repository layout

```
mac/       SwiftPM macOS app (SwiftUI, macOS 14+)
mobile/    Flutter client (same data schema, same Wi-Fi deploy)
website/   Next.js view (Vercel)
docs/      ARCHITECTURE · ROADMAP · UIUX · HELP
ai/        PROMPTS.md — every AI prompt used to build this
```

## Data

Everything lives in `UserDefaults` under `dailytrack.*`:

- `dailytrack.records` — `[yyyy-MM-dd: {trackerId: value}]`
- `dailytrack.game` — XP, coins, energy, badges, boss HP
- `dailytrack.experiments` — `[flagId: Bool]`
- `dailytrack.*` settings keys — theme, name, notification hours, Turso credentials

Export writes `DailyTrack-Export.json` and `DailyTrack.csv` to `~/Desktop`.

## Docs

- [Architecture](docs/ARCHITECTURE.md)
- [Roadmap](docs/ROADMAP.md)
- [UI/UX](docs/UIUX.md)
- [Help](docs/HELP.md)
- [AI prompts used](ai/PROMPTS.md)

## ICP

Muslim, ~40, serial entrepreneur (some wins, some failures), father, husband, lives in a small town, started as a software engineer. Time-poor, attention scattered, intentions huge. The product's job is to make the **minimum visible** and everything else disappear.

MIT licensed.
