"use client";

import { useMemo, useState } from "react";

type DayRecord = { values?: Record<string, number> };

type ExportBlob = {
  version?: number;
  exportedAt?: string;
  records?: Record<string, DayRecord>;
  game?: { xp?: number; coins?: number; badges?: string[]; totalCounts?: number };
};

const TARGETS: Record<string, { title: string; target: number; weekly?: boolean }> = {
  darood: { title: "Darood", target: 1100 },
  astaghfar: { title: "Astaghfar", target: 1100 },
  teentasbih: { title: "Teen Tasbih", target: 99 },
  nafil20: { title: "20 Rakat Nafil", target: 20 },
  chash: { title: "Chash Namaz", target: 2 },
  ishraq: { title: "Ishraq Namaz", target: 2 },
  zuhrsunnat: { title: "Zuhr Sunnat Ghairullah", target: 4 },
  namaz5: { title: "5 Daily Prayers", target: 5 },
  nightsleep: { title: "Night Sleep", target: 270 },
  morningsleep: { title: "Morning Sleep", target: 240 },
  sundayextra: { title: "Sunday Holiday Extra", target: 1, weekly: true },
  ismail: { title: "Talk to Ismail Bhai", target: 1 },
  madrasa: { title: "Visit Madrasa", target: 2, weekly: true },
};

const SAMPLE: ExportBlob = {
  records: {
    "2026-10-03": {
      values: {
        darood: 1100, astaghfar: 1100, teentasbih: 99, nafil20: 20,
        chash: 2, ishraq: 2, zuhrsunnat: 4, namaz5: 5,
        nightsleep: 270, morningsleep: 240, ismail: 1,
      },
    },
    "2026-10-02": { values: { darood: 900, namaz5: 5, nightsleep: 240, ismail: 1 } },
    "2026-10-01": { values: { darood: 1100, namaz5: 3 } },
  },
  game: { xp: 640, coins: 95, badges: ["firstStep", "darood1100", "streak7"], totalCounts: 4520 },
};

function scoreOf(rec: DayRecord | undefined): number {
  const daily = Object.entries(TARGETS).filter(([, t]) => !t.weekly);
  if (!rec || !rec.values) return 0;
  const sum = daily.reduce((acc, [id, t]) => acc + Math.min(1, (rec.values?.[id] ?? 0) / t.target), 0);
  return sum / daily.length;
}

export default function Home() {
  const [data, setData] = useState<ExportBlob>(SAMPLE);
  const [name, setName] = useState("sample data");

  const days = useMemo(() => {
    const entries = Object.entries(data.records ?? {}).sort((a, b) => b[0].localeCompare(a[0]));
    return entries.slice(0, 30).map(([day, rec]) => ({ day, score: scoreOf(rec), rec }));
  }, [data]);

  const kept = useMemo(() => Object.values(data.records ?? {}).filter((r) => scoreOf(r) >= 0.75).length, [data]);
  const best = useMemo(() => {
    let run = 0, bestRun = 0;
    for (const d of [...days].reverse()) {
      if (d.score >= 0.75) { run += 1; bestRun = Math.max(bestRun, run); } else run = 0;
    }
    return bestRun;
  }, [days]);

  async function onFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    const text = await file.text();
    try {
      const parsed = JSON.parse(text) as ExportBlob;
      setData(parsed);
      setName(file.name);
    } catch {
      alert("That file is not a DailyTrack JSON export.");
    }
  }

  return (
    <main>
      <h1>DailyTrack</h1>
      <p className="sub">
        Single-user daily tracker for zikir, namaz, rest and life. Load your{" "}
        <code>DailyTrack-Export.json</code> to see it here. Showing <b>{name}</b>.
      </p>

      <input type="file" accept="application/json" onChange={onFile} />

      <div className="stats">
        <div className="stat"><b>{kept}</b><span>days kept</span></div>
        <div className="stat"><b>{best}</b><span>best streak (loaded)</span></div>
        <div className="stat"><b>{data.game?.xp ?? 0}</b><span>XP</span></div>
        <div className="stat"><b>{data.game?.coins ?? 0}</b><span>coins</span></div>
        <div className="stat"><b>{data.game?.badges?.length ?? 0}</b><span>badges</span></div>
      </div>

      {days.map(({ day, score, rec }) => (
        <div className="card" key={day}>
          <div className="row">
            <div>
              <b>{day}</b>
              <div className="muted">
                {Object.entries(rec?.values ?? {})
                  .map(([id, v]) => `${TARGETS[id]?.title ?? id}: ${v}`)
                  .join(" · ") || "no data"}
              </div>
            </div>
            <span className="pill" style={score >= 0.75 ? {} : { background: "rgba(255,160,0,.18)", color: "#ffa000" }}>
              {Math.round(score * 100)}% {score >= 0.75 ? "kept" : "open"}
            </span>
          </div>
          <div className="bar"><span style={{ width: `${Math.round(score * 100)}%` }} /></div>
        </div>
      ))}

      <p className="muted">
        macOS app · Flutter mobile · this website all share the same{" "}
        <code>{"{ day: { trackerId: value } }"}</code> schema. Source:{" "}
        <a href="https://github.com/theikbhal/DailyTrack">github.com/theikbhal/DailyTrack</a>
      </p>
    </main>
  );
}
