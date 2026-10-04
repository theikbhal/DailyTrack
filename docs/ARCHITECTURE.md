# DailyTrack — System Architecture

## One schema, three clients

```
                 ┌──────────────────────────┐
                 │   DailyTrack record schema│
                 │  { day: { trackerId: n } } │
                 └────────────┬─────────────┘
            ┌─────────────────┼─────────────────┐
            ▼                 ▼                 ▼
     mac/ (Swift 14+)   mobile/ (Flutter)   website/ (Next.js)
     UserDefaults JSON   shared_preferences  REST route → JSON
     local only          same-WiFi deploy    Vercel
            │
            └── optional Turso sync stub (experiment flag `tursoSync`)
```

v1 is **local only on the Mac**. The Turso stub (Settings → Sync) stores a DB URL + token but does not write yet; it is deliberately gated behind an experiment flag so the default app has zero network code paths.

## mac/ — the shipping client

Pure SwiftPM executable, no Xcode project, no dependencies.

```
Sources/DailyTrack/
  Models.swift           Tracker, DayRecord, Levels, Fmt
  Trackers.swift         Catalog.all — the 13 trackers
  Store.swift            DayStore: records, scoring, streaks, week math, export/import
  Game.swift             GameState: XP, coins, energy, badges, bosses
  Experiments.swift      ExperimentsManager: [flagId: Bool] for trackers + features
  Settings.swift         AppSettings singleton + Pref key constants
  Theme.swift            AppTheme (8 themes incl. Dark) + ThemeManager
  NotificationEngine.swift  UNUserNotificationCenter wrapper
  SelfTest.swift         swift run DailyTrack --selftest
  UI/                    Root, Today, Calendar, Progress, Encourage, Help, Settings, Onboarding, Abacus, Shared
```

### Data flow

1. User taps a bead / +1 / mark-done → `TodayView.update(tracker, newValue)`
2. `DayStore.set` writes the record and persists `dailytrack.records` immediately (no save button)
3. `Game.valueChanged` awards XP/coins, damages enemies on target crossings
4. `Game.reconcile` awards the kept-day bonus once per date, heals enemies for a missed day, unlocks new badges
5. Completion fires a one-shot local notification

### Scoring

```
score(day)   = mean( min(value/target, 1) ) over ENABLED DAILY trackers
kept(day)    = score(day) >= 0.75
streak       = consecutive kept days ending today (or yesterday if today is open)
weekly items (madrasa, Sunday extra) are excluded from the daily score
```

### Gamification

| Currency | Earn | Spend |
|---|---|---|
| XP | +20 tracker complete · +50 kept day · +30 badge · +100 boss defeat · +25 push-through | levels (0/200/500/1000/2000/3500/6000/10000) |
| Coins | +5 tracker · +25 kept day · +15 badge · +50 boss | 30 = full energy refill |
| Energy | 1 per 30 min, max 10 + 2/level | 2 per push-through |
| Boss HP | laziness ← zikir completes, weakHealth ← rest completes | +15 heal per missed day, −20 per kept day, respawn at 100×(1+0.25·level) |

### Experiment flags

`ExperimentsManager` persists `[String: Bool]` under `dailytrack.experiments`.
Every one of the 13 trackers is a flag (`darood`, `astaghfar`, …) plus feature flags: `onboarding, abacus, calendar, encourage, enemies, rewards, confetti, notifications, tursoSync`.
Missing key → declared `defaultEnabled`.

### Notifications

| id | trigger | notes |
|---|---|---|
| `dailytrack.morning` | daily hour:00 (default 6) | re-scheduled on every settings change |
| `dailytrack.midday` | daily hour:30 (default 13) | |
| `dailytrack.evening` | daily hour:00 (default 20) | |
| `dailytrack.done.<id>.<date>` | 1 s one-shot | tracker completion |
| `dailytrack.test.<ts>` | 1 s one-shot | Settings → Send test |

`reschedule()` is a full `removeAllPendingNotificationRequests()` + re-add (SalatTasbi pattern), gated on the `notifications` experiment flag.

## mobile/ (planned)

Flutter, `shared_preferences` JSON with the exact same `{day: {id: value}}` shape. Deploy to a device on the same Wi-Fi: `flutter run -d <device>`.

## website/ (planned)

Next.js app router, read-only dashboard over the exported JSON, `vercel --prod`.

## Future sync (1.1)

Turso libSQL HTTP pipeline (`/v2/pipeline`, `Authorization: Bearer <token>`) — the same pattern already proven in `mac_apps/ZikirGoals`. Tables: `dailytrack_records(day, tracker_id, value)`, `dailytrack_game(...)`. Local stays source of truth; sync is push-then-pull.
