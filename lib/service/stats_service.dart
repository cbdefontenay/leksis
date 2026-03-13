import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static const String _statsKey = 'app_activity_stats';

  Future<void> logWordAdded() async {
    await _logEvent('added');
  }

  Future<void> logWordLearned() async {
    await _logEvent('learned');
  }

  Future<void> _logEvent(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey) ?? '{}';
    final Map<String, dynamic> stats = json.decode(statsJson);

    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    if (!stats.containsKey(monthKey)) {
      stats[monthKey] = {'added': 0, 'learned': 0};
    }

    stats[monthKey][type] = (stats[monthKey][type] ?? 0) + 1;

    await prefs.setString(_statsKey, json.encode(stats));
  }

  Future<Map<String, Map<String, int>>> getMonthlyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey) ?? '{}';
    final Map<String, dynamic> rawStats = json.decode(statsJson);

    final Map<String, Map<String, int>> result = {};
    rawStats.forEach((key, value) {
      result[key] = {
        'added': value['added'] as int,
        'learned': value['learned'] as int,
      };
    });

    return result;
  }
}
