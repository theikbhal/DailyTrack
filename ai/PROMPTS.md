# AI prompts used to build DailyTrack

Every prompt below was sent to an AI coding agent (opencode, model mimo-v2.6-flash-free) while building this repository, in order.

---

## 1. The original build brief (verbatim)

```
1. build mac app
	1. zikir track
		1. darood  1100
		2. astagafar 1100
		3. teentasbi
		4. 20 rakat nafil
		5. chash namaz
		6. ishraq namaz
		7. chash namaz
		8. spent time on holiday sunday more time
		9. 4 to 5 hour night sleep
		10. monrning sleep 4 hours sleep
		11. zuhr 30 minute sunnath khailullah
		12. namaz track
	2. enable disable each one at experiments flags in setitn
	3. dark mode
	4. github repo
	5. desktop shortcut
	6. move to applciations
	7. add this app to apptracker mac app local installed
	8. daily push notificaiotn
	9. talk to ismail bhail dryfruits daily if possible
	10. visit madaras weekly once or twice
	11. swift app mac
	12. onboardign
	13. help doc
	14. road map( feature implemented, missed one, bugs, improve )
	15. streaks
	16. levels
	17. badges
	18. encourage
	19. daily push notificaiton
	20. zikir counter attach - visualize with abacus
	21. ---
	22. mac folder -> sseperate
	23. mobile view  -> flutter , deploy to mobile on same wifi, seperate folder
	24. website view -> seperate folder , vercel deploy
	25. --
	26. local storage
	27. back to turos.tech
	28. api given already in previous chats check
	29. export data
	30. import data llow
	31. calendar views
	32. gamify coins , energy, enemeie(laziness, weak health, otehr...)
	33. ---
	34. system architecture
	35. ai forlder ai frompts used
	36. ui ux design
	37. ---
	38. single user , single person
	39. icp adhd users, muslim, 40 y ears, serioal enterepreneru, failed, father, husband, living in small down, early wokred as software engineer too
```

## 2. Scope decision (user answers to agent questions)

```
Q: App + repo name?            A: "daily track minimum"
Q: Name clarification?         A: "DailyTrack - minimal"
Q: How deep this session?      A: "Full plan, all 6 phases"
Q: Cloud sync items 27/28?     A: "Local-only v1 + Turso stub behind flag"
```

## 3. Ship instruction (user, after plan approval)

```
lets me know if done
create destop shortcut
mvoe to applciations
open it
```

---

## Research prompts sent to explore agents before any code was written

```
1. Explore ZikirSprint + SalatTasbi: Package.swift, build scripts, store/persistence
   pattern, gamification, notification engine, settings/theme, onboarding/help,
   abacus UI, export/import, docs. Return exact paths and exact build commands.

2. Explore DaroodTracker: build pipeline, ExperimentsManager pattern (shape of code
   so I can replicate), CalendarView data source, notification engines, onboarding/
   help, icon generation, plus a cross-repo survey of scripts that install to
   /Applications or create desktop shortcuts.

3. Search Desktop + opencode config for "turos.tech", any previously defined zikir
   API (Turso/Supabase/REST), paired Flutter/Next.js folders, gh auth status,
   an "ai/" folder convention, and the ~/.project-tracker/projects.json schema.
```

## Agent synthesis prompt (the actual build instruction)

```
Build DailyTrack: a minimal, ADHD-first single-user macOS SwiftUI app
(SwiftPM, macOS 14+) in mac/, with 13 trackers, one experiment flag per tracker,
abacus counter, calendar day/week/month/year, streaks/8 levels/16 badges/coins/
energy/two enemies, daily push notifications, encourage tab, onboarding, help +
roadmap, export/import JSON+CSV, 8 themes incl. dark, --selftest harness;
reuse ExperimentsManager pattern from DaroodTracker, Gamification from
ZikirSprint, BoardView geometry from AbacusToy, build_app.sh from ZikirSprint.
Then docs/ (ARCHITECTURE, ROADMAP, UIUX, HELP), ai/PROMPTS.md, GitHub repo
theikbhal/DailyTrack, Flutter scaffold in mobile/, Next.js scaffold in website/.
```

## Verification commands the agent ran

```bash
cd mac && swift build
swift run DailyTrack --selftest          # 30 assertions → ALL TESTS PASSED
./scripts/build_app.sh                   # build + icon + icns + codesign +
                                         # /Applications + Desktop symlink +
                                         # AppTracker registration
open /Applications/DailyTrack.app && pgrep -x DailyTrack
```

## Prompt-engineering notes for future sessions

- **Reuse before rewrite:** the sibling repos in `mac_apps/` already solved build,
  icons, install, experiments, notifications and gamification. Asking an agent to
  *survey first* beat any amount of greenfield design.
- **One model of the data:** `{ day: { trackerId: value } }` kept mac, mobile and
  website interchangeable with zero translation layer.
- **Flags instead of features:** making every tracker a boolean flag meant the ADHD
  "too much UI" problem was solved in the data model, not the layout.
- **Testability over coverage:** `--selftest` runs pure functions on an isolated
  `DayStore` (`enabledOverride` + in-memory records) so assertions never touch
  real user data.
