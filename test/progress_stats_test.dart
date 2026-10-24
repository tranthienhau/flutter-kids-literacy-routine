import 'package:flutter_test/flutter_test.dart';
import 'package:hopscotch/data/models/content.dart';
import 'package:hopscotch/data/models/progress.dart';
import 'package:hopscotch/data/seed.dart';
import 'package:hopscotch/domain/progress_stats.dart';

void main() {
  final now = DateTime(2026, 10, 24, 19);

  test('seed gives a 6 day streak ending today', () {
    expect(ProgressStats(seedProgress(now), now).streak, 6);
  });

  test('streak survives until the child reads today', () {
    final s = ProgressState(
      sessions: [
        SessionRecord(
          'a',
          'sounds',
          now.subtract(const Duration(days: 1)),
          3,
          const [],
        ),
        SessionRecord(
          'a',
          'sounds',
          now.subtract(const Duration(days: 2)),
          3,
          const [],
        ),
      ],
      baseSkill: const {},
    );
    expect(ProgressStats(s, now).streak, 2);
  });

  test('read-along cursor follows word timestamps', () {
    const p = ReadAlongPayload('x', Duration(seconds: 3), [
      [
        TimedWord('Sam', Duration.zero, Duration(milliseconds: 400)),
        TimedWord(
          'has',
          Duration(milliseconds: 540),
          Duration(milliseconds: 900),
        ),
      ],
      [
        TimedWord(
          'map.',
          Duration(milliseconds: 1200),
          Duration(milliseconds: 1600),
        ),
      ],
    ], []);
    expect(p.cursorAt(const Duration(milliseconds: 600)), (line: 0, word: 1));
    expect(p.cursorAt(const Duration(milliseconds: 1300)), (line: 1, word: 0));
  });
}
