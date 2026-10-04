import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tracker {
  final String id;
  final String title;
  final String detail;
  final String category;
  final int target;
  final String unit;
  final bool weekly;
  final bool counter;

  const Tracker({
    required this.id,
    required this.title,
    required this.detail,
    required this.category,
    required this.target,
    required this.unit,
    this.weekly = false,
    this.counter = false,
  });
}

const trackers = <Tracker>[
  Tracker(id: 'darood', title: 'Darood', detail: '1100 daily', category: 'Zikir', target: 1100, unit: 'counts', counter: true),
  Tracker(id: 'astaghfar', title: 'Astaghfar', detail: '1100 daily', category: 'Zikir', target: 1100, unit: 'counts', counter: true),
  Tracker(id: 'teentasbih', title: 'Teen Tasbih', detail: '33 x 3 after each prayer', category: 'Zikir', target: 99, unit: 'counts', counter: true),
  Tracker(id: 'nafil20', title: '20 Rakat Nafil', detail: '12 + 4 + 2 + 2', category: 'Namaz', target: 20, unit: 'rakat'),
  Tracker(id: 'chash', title: 'Chash Namaz', detail: '2 rakat after sunrise', category: 'Namaz', target: 2, unit: 'rakat'),
  Tracker(id: 'ishraq', title: 'Ishraq Namaz', detail: '2 rakat ~20 min after sunrise', category: 'Namaz', target: 2, unit: 'rakat'),
  Tracker(id: 'zuhrsunnat', title: 'Zuhr Sunnat Ghairullah', detail: '4 rakat, 30 minutes free', category: 'Namaz', target: 4, unit: 'rakat'),
  Tracker(id: 'namaz5', title: '5 Daily Prayers', detail: 'Fajr to Isha', category: 'Namaz', target: 5, unit: 'prayers'),
  Tracker(id: 'nightsleep', title: 'Night Sleep', detail: '4 to 5 hours', category: 'Rest', target: 270, unit: 'min'),
  Tracker(id: 'morningsleep', title: 'Morning Sleep', detail: '4 hour nap window', category: 'Rest', target: 240, unit: 'min'),
  Tracker(id: 'sundayextra', title: 'Sunday Holiday Extra', detail: 'More worship and family', category: 'Life', target: 1, unit: 'done', weekly: true),
  Tracker(id: 'ismail', title: 'Talk to Ismail Bhai', detail: 'Dryfruits call', category: 'Life', target: 1, unit: 'done'),
  Tracker(id: 'madrasa', title: 'Visit Madrasa', detail: 'Once or twice a week', category: 'Life', target: 2, unit: 'visits', weekly: true),
];

String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() => runApp(const DailyTrackApp());

class DailyTrackApp extends StatelessWidget {
  const DailyTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyTrack',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF0E9FAE), useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF0E9FAE), brightness: Brightness.dark, useMaterial3: true),
      home: const TodayPage(),
    );
  }
}

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  Map<String, dynamic> _data = {'records': <String, dynamic>{}};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('dailytrack.records');
    if (raw != null) {
      try {
        _data = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dailytrack.records', jsonEncode(_data));
  }

  Map<String, dynamic> get _today {
    final records = (_data['records'] as Map<String, dynamic>?) ?? {};
    return (records[dayKey(DateTime.now())] as Map<String, dynamic>?) ?? <String, dynamic>{};
  }

  void _set(String id, int value) {
    final records = (_data['records'] as Map<String, dynamic>?) ?? {};
    final day = (records[dayKey(DateTime.now())] as Map<String, dynamic>?) ?? {};
    day[id] = value < 0 ? 0 : value;
    records[dayKey(DateTime.now())] = day;
    _data['records'] = records;
    _save();
    setState(() {});
  }

  double _score() {
    final daily = trackers.where((t) => !t.weekly).toList();
    if (daily.isEmpty) return 0;
    final today = _today;
    final sum = daily.fold<double>(0, (acc, t) {
      final v = (today[t.id] as int?) ?? 0;
      final p = v / t.target;
      return acc + (p > 1 ? 1 : p);
    });
    return sum / daily.length;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final score = _score();
    final categories = trackers.map((t) => t.category).toSet().toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyTrack'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${(score * 100).round()}%',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(score >= 0.75 ? 'Day kept - MashaAllah' : 'Day in progress',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: score, minHeight: 8, borderRadius: BorderRadius.circular(8)),
                  const SizedBox(height: 8),
                  const Text('A day counts at 75% average across your enabled trackers.',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          for (final category in categories) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
              child: Text(category.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            ),
            for (final t in trackers.where((t) => t.category == category)) _tile(t),
          ],
        ],
      ),
    );
  }

  Widget _tile(Tracker t) {
    final value = (_today[t.id] as int?) ?? 0;
    final progress = (value / t.target).clamp(0.0, 1.0);
    final done = value >= t.target;
    final steps = t.counter ? [1, 10, 100] : [t.target > 20 ? 30 : 1];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text('$value / ${t.target} ${t.unit}',
                    style: TextStyle(color: done ? Colors.green : null)),
              ],
            ),
            Text(t.detail, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: progress, minHeight: 6),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _set(t.id, value - 1),
                ),
                for (final s in steps)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilledButton(
                      onPressed: () => _set(t.id, value + s),
                      child: Text('+$s'),
                    ),
                  ),
                const Spacer(),
                if (done)
                  const Icon(Icons.check_circle, color: Colors.green)
                else
                  OutlinedButton(
                    onPressed: () => _set(t.id, t.target),
                    child: const Text('Done'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
