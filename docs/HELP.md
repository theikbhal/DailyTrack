# DailyTrack — Help

## Getting started

DailyTrack shows one screen: **Today**. Every card is a tracker. Switch trackers on or off in **Settings → Experiments** — if you are only doing darood this month, turn off everything else and the app becomes a darood app.

A day is **kept** when your enabled daily trackers average **75%**. Kept days build your streak.

## Counting zikir

Darood, Astaghfar and Teen Tasbih use the **abacus**:

- Tap a bead to set the digit (heaven bead = 5, earth beads = 1 each)
- Or use **+1 / +10 / +100**, **-1**, **Reset**
- Every tap saves instantly — there is no save button

## Namaz trackers

Tap **+1** per rakat, or **Mark done** when finished:
20 Rakat Nafil · Chash (2) · Ishraq (2) · Zuhr Sunnat Ghairullah (4 rakat, keep 30 minutes free after Zuhr) · 5 Daily Prayers.

## Rest and life

Night sleep and morning sleep use **±30 min** steps. Sunday extra time and the madrasa visit count per week; the Ismail bhai call counts daily.

## Streaks, levels, badges

- **Streak** = consecutive kept days (current / longest / total kept in Progress)
- **XP**: +20 per completed tracker, +50 per kept day, +30 per badge
- **8 levels**: Newcomer → Consistent → Steady → Devoted → Disciplined → Focused → Master → Legend
- **16 badges**: Darood 1100, Astaghfar 1100, Teen Tasbih, Five Prayers, streaks 7/30, Perfect Day, and more
- **Coins**: 30 coins buy a full energy refill

## Enemies and energy

Laziness and Weak Health are bosses with HP bars (Progress tab). Completing zikir damages laziness, completing rest damages weak health, a kept day deals 20 damage, a missed day heals them 15. Energy refills 1 block / 30 min; **Push through** in the Encourage tab spends 2 energy for 25 XP.

## Notifications

Three daily nudges: morning (6:00), midday (13:30), evening (20:00). Change hours in **Settings → Notifications**, send a test there too. Tracker completions fire a "MashaAllah" alert.

If macOS blocks them: System Settings → Notifications → DailyTrack → Allow.

## Export, import, reset

**Settings → Data**

- **Export JSON** → `~/Desktop/DailyTrack-Export.json`
- **Export CSV** → `~/Desktop/DailyTrack.csv`
- **Import JSON** → replaces all records with a previous export
- **Reset everything** → deletes records, XP, coins, badges and flags (asks first)

All data is local: `dailytrack.*` keys in UserDefaults. No account, no network.

## Themes / dark mode

Settings → Appearance → 8 themes including Dark and Light. Your choice is remembered.

## Roadmap

See [ROADMAP.md](ROADMAP.md) — shipped in 1.0, next (menu bar quick count, weekly review, prayer-time reminders, mobile, website), known bugs, wanted improvements.

## FAQ

**Why 75% and not 100%?** Perfection breaks streaks. The minimum keeps you in the game.
**Can I change a target?** Not in 1.0 — switch the tracker off instead.
**Where is my data?** `~/Desktop/DailyTrack-Export.json` after you export.
**Phone app?** `mobile/` in the repo is the Flutter start; same schema.
**Replay onboarding?** Settings is not required — press ⇧⌘O or use Day → Reset onboarding.
