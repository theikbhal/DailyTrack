#!/usr/bin/env python3
"""Upsert DailyTrack into AppTracker's apps.json."""
import json
import os
import uuid
from datetime import datetime, timezone

path = os.path.expanduser("~/Library/Application Support/AppTracker/apps.json")
name = "DailyTrack"

now_ref = datetime.now(timezone.utc).timestamp() - 978307200

entry = {
    "name": name,
    "githubRepo": "https://github.com/theikbhal/DailyTrack",
    "localPath": os.path.expanduser("~/Desktop/mac_apps/DailyTrack"),
    "colorHex": "#0E9FAE",
    "dateAdded": now_ref,
    "id": str(uuid.uuid4()).upper(),
    "howToRun": "open /Applications/DailyTrack.app  |  ./scripts/build_app.sh  |  ./scripts/build_app.sh --build-only  |  swift run DailyTrack --selftest",
    "notes": (
        "Single-user daily tracker for zikir, namaz, rest and life: darood 1100, "
        "astaghfar 1100, teen tasbih, 20 rakat nafil, chash, ishraq, zuhr sunnat "
        "ghairullah, 5 prayers, night sleep 4-5h, morning sleep 4h, Sunday extra "
        "time, Ismail bhai call, madrasa visit. Abacus counter, calendar views, "
        "streaks, 8 levels, 16 badges, coins, energy, laziness/weak-health enemies, "
        "daily push notifications, per-tracker experiment flags, export/import, "
        "8 themes with dark mode. Local-only storage under dailytrack.*."
    ),
    "bundlePath": "/Applications/DailyTrack.app",
}

os.makedirs(os.path.dirname(path), exist_ok=True)
apps = []
if os.path.exists(path):
    with open(path) as f:
        apps = json.load(f)

for i, a in enumerate(apps):
    if a.get("name") == name or a.get("bundlePath") == entry["bundlePath"]:
        merged = dict(entry)
        merged["id"] = a.get("id") or entry["id"]
        merged["dateAdded"] = a.get("dateAdded") or entry["dateAdded"]
        apps[i] = merged
        break
else:
    apps.append(entry)

tmp = path + ".tmp"
with open(tmp, "w") as f:
    json.dump(apps, f, indent=2)
os.replace(tmp, path)
print(f"registered {name} in {path} ({len(apps)} apps)")
