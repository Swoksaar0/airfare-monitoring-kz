import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flight_models.dart';

class MonitorState extends ChangeNotifier {
  MonitorState(this.prefs, {required this.demo, DateTime Function()? now})
      : now = now ?? DateTime.now {
    departure = calendarDate(this.now()).add(const Duration(days: 7));
    final saved = prefs.getString(storageKey);
    if (saved == null) return;
    try {
      final data = jsonDecode(saved) as Map<String, dynamic>;
      _favorites = (data['favorites'] as List<dynamic>).cast<String>().toSet();
      _rules = (data['rules'] as List<dynamic>)
          .map((r) => TrackingRule.fromJson(r as Map<String, dynamic>))
          .toList();
      final date = DateTime.parse(data['departure'] as String);
      if (calendarDate(date).isAfter(calendarDate(this.now()))) {
        departure = date;
      }
    } catch (_) {
      storageWarning = 'Сохранённые настройки не удалось прочитать. '
          'Файл настроек не изменён. Можно продолжить с новыми настройками.';
    }
  }
  final SharedPreferences prefs;
  final bool demo;
  final DateTime Function() now;
  String get storageKey => 'airfare_monitor_v2_${demo ? 'demo' : 'api'}';
  Set<String> _favorites = {};
  List<TrackingRule> _rules = [];
  late DateTime departure;
  String? storageWarning;
  Future<void> _writes = Future<void>.value();

  Set<String> get favorites => Set.unmodifiable(_favorites);
  List<TrackingRule> get rules => List.unmodifiable(_rules);
  bool isFavorite(FlightRoute route) => _favorites.contains(route.key);
  TrackingRule? ruleFor(FlightRoute route, DateTime date) {
    final key = '${route.key}|${dateKey(date)}';
    for (final rule in _rules) {
      if (rule.key == key) return rule;
    }
    return null;
  }

  // Serialize writes and publish memory state only after a successful write.
  Future<void> _mutate(void Function(Set<String>, List<TrackingRule>) update,
      {DateTime? selectedDate}) {
    final operation = _writes.then((_) async {
      final favorites = {..._favorites};
      final rules = [..._rules];
      update(favorites, rules);
      final nextDate = selectedDate ?? departure;
      final saved = await prefs.setString(
          storageKey,
          jsonEncode({
            'favorites': favorites.toList()..sort(),
            'rules': rules.map((r) => r.toJson()).toList(),
            'departure': dateKey(nextDate),
          }));
      if (!saved) throw StateError('Local storage write failed');
      _favorites = favorites;
      _rules = rules;
      departure = nextDate;
      storageWarning = null;
      notifyListeners();
    });
    _writes = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> selectDate(DateTime value) {
    final date = calendarDate(value);
    if (!date.isAfter(calendarDate(now()))) {
      throw ArgumentError('Departure must be in the future');
    }
    return _mutate((_, __) {}, selectedDate: date);
  }

  Future<void> toggleFavorite(FlightRoute route) => _mutate((favorites, _) {
        if (!favorites.remove(route.key)) favorites.add(route.key);
      });

  Future<void> saveRule(FlightRoute route, DateTime date, int minor) {
    if (minor <= 0 || !calendarDate(date).isAfter(calendarDate(now()))) {
      throw ArgumentError('Invalid tracking rule');
    }
    final rule = TrackingRule(
        route: route,
        departureDate: dateKey(date),
        thresholdMinor: minor,
        createdAt: now().toUtc());
    return _mutate((_, rules) {
      rules.removeWhere((r) => r.key == rule.key);
      rules.add(rule);
    });
  }

  Future<void> setRuleActive(TrackingRule rule, bool active) {
    if (active && rule.expired(now())) throw ArgumentError('Expired departure');
    return _mutate((_, rules) {
      final index = rules.indexWhere((r) => r.key == rule.key);
      if (index < 0) throw StateError('Rule no longer exists');
      rules[index] = rules[index].withActive(active);
    });
  }

  Future<void> removeRule(TrackingRule rule) =>
      _mutate((_, rules) => rules.removeWhere((r) => r.key == rule.key));
}

