import '../data/models/content.dart';
import '../data/models/progress.dart';

DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

/// Pure functions over the session log, unit-testable without Flutter.
class ProgressStats {
  final ProgressState state;
  final DateTime today;
  ProgressStats(this.state, DateTime now) : today = dayOf(now);

  Set<DateTime> get _activeDays =>
      state.sessions.map((s) => dayOf(s.day)).toSet();

  /// Consecutive active days ending today (or yesterday, so the streak is not "lost"
  /// before the child has had a chance to read today).
  int get streak {
    final days = _activeDays;
    var cursor = days.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    var n = 0;
    while (days.contains(cursor)) {
      n++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// Mon..Sun of the current week: true when the child read that day.
  List<bool> get week {
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final days = _activeDays;
    return List.generate(
      7,
      (i) => days.contains(monday.add(Duration(days: i))),
    );
  }

  int get minutesThisWeek {
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return state.sessions
        .where((s) => !dayOf(s.day).isBefore(monday))
        .fold(0, (a, s) => a + s.minutes);
  }

  int get totalMinutes => state.sessions.fold(0, (a, s) => a + s.minutes);
  int get wordsLearned =>
      state.sessions.expand((s) => s.newWords).toSet().length;
  int count(String category) =>
      state.sessions.where((s) => s.category == category).length;
  Set<String> doneToday() => state.sessions
      .where((s) => dayOf(s.day) == today)
      .map((s) => s.activityId)
      .toSet();
  List<SessionRecord> get todaySessions =>
      state.sessions.where((s) => dayOf(s.day) == today).toList();

  /// Skill progress per category: placement baseline plus 3 points per completed activity.
  double skill(String category) =>
      ((state.baseSkill[category] ?? 0) + 3 * count(category)).clamp(0, 100) /
      100;

  int metric(String name) => switch (name) {
    'stories' => count('stories'),
    'sounds' => count('sounds'),
    'rhymes' => count('rhymes'),
    'streak' => streak,
    'words' => wordsLearned,
    'minutes' => totalMinutes,
    _ => 0,
  };

  double achievementProgress(AchievementDef a) =>
      (metric(a.metric) / a.target).clamp(0, 1).toDouble();
  bool earned(AchievementDef a) => metric(a.metric) >= a.target;
}

/// Builds today's curated routine for the child's stage from the content catalog.
class RoutineBuilder {
  static List<Activity> build(Catalog catalog, ChildProfile child) =>
      (catalog.routines[child.stage.key] ?? catalog.routines.values.first)
          .map(catalog.byId)
          .toList();
}
