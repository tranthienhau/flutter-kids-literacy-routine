import 'models/progress.dart';

/// Demo data: Maya (5) has read five days in a row and finished the first activity today.
const seedChild = ChildProfile(
  name: 'Maya',
  age: 5,
  stage: ReadingStage.justStarting,
  avatar: 'assets/images/avatar-maya.jpg',
);

ProgressState seedProgress(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  DateTime ago(int d) =>
      today.subtract(Duration(days: d)).add(const Duration(hours: 19));
  const words = [
    ['am', 'an', 'at'],
    ['ant', 'and', 'as'],
    ['sat', 'sad', 'sap'],
    ['map', 'mad', 'man'],
    ['pan', 'pat', 'pad'],
    ['tap', 'tan', 'tab'],
    ['can', 'cap', 'cab'],
    ['fan', 'fat', 'fin'],
    ['big', 'bit', 'bin'],
    ['dig', 'dip', 'did'],
    ['sit', 'sip', 'six'],
    ['red', 'bed', 'fed'],
  ];
  final sessions = <SessionRecord>[];
  const plan = [
    [5, 'letter-short-a', 'sounds', 3],
    [5, 'story-pip-hat', 'stories', 5],
    [4, 'tap-cat-sat', 'sounds', 3],
    [4, 'read-map-for-sam', 'reading', 4],
    [4, 'rhyme-with-cat', 'rhymes', 3],
    [3, 'letter-m-walk', 'sounds', 2],
    [3, 'story-big-red-bus', 'stories', 6],
    [3, 'read-map-for-sam', 'reading', 4],
    [2, 'short-a-sounds', 'sounds', 3],
    [2, 'story-pip-hat', 'stories', 5],
    [2, 'rhyme-with-cat', 'rhymes', 3],
    [1, 'tap-cat-sat', 'sounds', 3],
    [1, 'story-big-red-bus', 'stories', 6],
    [1, 'read-map-for-sam', 'reading', 4],
  ];
  for (var i = 0; i < plan.length; i++) {
    final p = plan[i];
    sessions.add(
      SessionRecord(
        p[1] as String,
        p[2] as String,
        ago(p[0] as int),
        p[3] as int,
        words[i % words.length],
      ),
    );
  }
  sessions.add(
    SessionRecord(
      'letter-short-a',
      'sounds',
      today.add(const Duration(hours: 18)),
      3,
      const ['ant', 'apple'],
    ),
  );
  return ProgressState(
    sessions: sessions,
    baseSkill: const {'sounds': 52, 'reading': 33, 'stories': 48, 'rhymes': 22},
  );
}
