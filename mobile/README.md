# DailyTrack — mobile (Flutter)

Same tracker list, same `{ day: { trackerId: value } }` schema as the macOS app. Storage: `shared_preferences` key `dailytrack.records`.

```bash
cd mobile
flutter pub get
flutter devices                 # find your phone/emulator
flutter run -d <device-id>      # phone and Mac on the same Wi-Fi
```

Shipped in 1.0: Today screen with all 13 trackers, +/- counting, done buttons, day score. Not yet: streaks, calendar, gamification, sync.
