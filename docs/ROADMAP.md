# DailyTrack Roadmap

## Shipped — 1.0

| Feature | State |
|---|---|
| 13 trackers (darood 1100, astaghfar 1100, teen tasbih, 20 rakat nafil, chash, ishraq, zuhr sunnat ghairullah, 5 prayers, night sleep 4–5 h, morning sleep 4 h, Sunday extra, Ismail bhai call, madrasa) | done |
| Per-tracker + per-feature experiment flags in Settings | done |
| Abacus counter (5-rod, tap beads to set digits) | done |
| Calendar: day / week / month / year | done |
| Streaks, 8 levels, 16 badges | done |
| Coins, energy, two enemies (Laziness, Weak Health) | done |
| Daily push notifications (morning/midday/evening) + completion alerts | done |
| Encourage tab + push-through boost | done |
| Onboarding (4 slides) and Help doc with roadmap | done |
| Export JSON / CSV, import JSON | done |
| Dark mode + 7 other themes | done |
| Desktop shortcut, `/Applications` install, AppTracker registration | done |
| `--selftest` harness (30 assertions) | done |
| GitHub repo, architecture/UIUX/help docs, AI prompt log | done |

## Missed from the original list (deferred, not forgotten)

| Item | Why | Planned |
|---|---|---|
| turos.tech / "API from previous chats" | No API found anywhere on disk | 1.1 — Turso stub is in place, needs token |
| Flutter mobile on same Wi-Fi | scaffold only this pass | 1.1 |
| Website view on Vercel | scaffold only this pass | 1.1 |
| Calendar hijri dates | needs a hijri library | 1.2 |
| Prayer-time-aware reminders | needs adhan/ICS source | 1.1 |

## Next — 1.1

- Menu bar quick-count (count darood without opening the window)
- Weekly review screen (what slipped, what held)
- Per-tracker target editing in Settings
- iCloud / Turso JSON round-trip
- Prayer-time aware notification windows
- Mobile client running on the same Wi-Fi

## Next — 1.2

- Hijri dates and Ramadan mode
- Drag-to-count on the abacus (currently tap)
- Website dashboard on Vercel fed by export
- Printable 30-day streak sheet

## Known bugs / rough edges (open)

1. Year view only remembers the selected year while the app is open (not persisted).
2. Streaks treat every enabled daily tracker with equal weight — disabling two trackers changes past kept-day scores retroactively.
3. Weekly trackers (madrasa, Sunday extra) have no week-boundary nudge notification.
4. Onboarding sheet can be dismissed with Esc, which re-shows it on next launch (by design, but it is not obvious).
5. Abacus caps at 99999 per tracker per day.

## Improvements wanted

- Per-tracker history sparklines in Progress
- Enemy AI: names that change with level, weekly boss rotation
- Sound + haptics on bead taps
- "Restart the day" quick action after a bad morning
- Energy costs tied to tracker difficulty (1100 darood costs nothing today)

## Non-negotiable principles

1. Local-first: the app must be fully useful with no network.
2. 75%, never 100%: the minimum must be achievable on the worst day.
3. Every feature must be switchable off — one screen, not fourteen.
4. Single user. No accounts, no social, no leaderboards.
