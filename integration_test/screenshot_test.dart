import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hopscotch/app/app.dart';
import 'package:hopscotch/app/router.dart';
import 'package:hopscotch/features/library/filter_sheet.dart';
import 'package:hopscotch/state/providers.dart';
import 'package:integration_test/integration_test.dart';

/// Drives the real app through onboarding, today's routine, each activity type, progress,
/// library, filters, story detail and the parent area, capturing one PNG per key screen.
/// Uses fixed pump(Duration) steps (audio and animations keep running, so no pumpAndSettle).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var converted = false;
  // Fixed Saturday evening so greeting, streak and week row are stable.
  final now = DateTime(2026, 10, 24, 19, 10);

  Future<void> settle(WidgetTester t, [int ms = 900]) async {
    for (var i = 0; i < ms ~/ 100; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> shoot(WidgetTester t, String name) async {
    if (!converted) {
      await binding.convertFlutterSurfaceToImage();
      converted = true;
    }
    await settle(t, 700);
    await binding.takeScreenshot(name);
  }

  Future<void> tap(WidgetTester t, Finder f, [int ms = 1100]) async {
    await t.ensureVisible(f.first);
    await settle(t, 200);
    await t.tap(f.first, warnIfMissed: false);
    await settle(t, ms);
  }

  testWidgets('capture Hopscotch flows', (t) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [clockProvider.overrideWithValue(() => now)],
        child: const HopscotchApp(),
      ),
    );
    await settle(t, 2000);
    final c = ProviderScope.containerOf(t.element(find.byType(HopscotchApp)));
    GoRouter router() => c.read(routerProvider);

    await shoot(t, '01-welcome');
    await tap(t, find.byKey(const Key('get-started')));
    await shoot(t, '02-child-setup');
    await tap(t, find.byKey(const Key('build-routine')), 1800);
    await shoot(t, '03-today');

    // Activity 2: tap words
    await tap(t, find.byKey(const Key('continue')), 1500);
    await tap(t, find.byKey(const Key('word-cat')), 600);
    await tap(t, find.byKey(const Key('phoneme-1')), 300);
    await shoot(t, '04-tap-words');
    await tap(t, find.byKey(const Key('next')), 1500);
    await shoot(t, '05-activity-complete');

    // Activity 3: read along, with the passage cursor on line 3
    await tap(t, find.byKey(const Key('next-activity')), 1500);
    final ra =
        t.state(
              find.byWidgetPredicate(
                (w) => w.runtimeType.toString() == 'ReadAlongView',
              ),
            )
            as dynamic;
    ra.jumpTo(const Duration(milliseconds: 7500));
    await settle(t, 400);
    await shoot(t, '06-read-along');
    await tap(t, find.byKey(const Key('next')), 1500);

    // Activity 4: storybook, page 3
    await tap(t, find.byKey(const Key('next-activity')), 1500);
    await tap(t, find.byKey(const Key('next-page')), 800);
    await tap(t, find.byKey(const Key('next-page')), 800);
    await shoot(t, '07-storybook');
    await tap(t, find.byKey(const Key('next-page')), 800);
    await tap(t, find.byKey(const Key('next-page')), 1500);
    await tap(t, find.byKey(const Key('next-activity')), 1800);
    await shoot(t, '08-today-done');

    router().go('/progress');
    await settle(t, 1200);
    await shoot(t, '09-progress');
    router().go('/progress/achievements');
    await settle(t, 1200);
    await shoot(t, '10-achievements');

    router().go('/library');
    await settle(t, 1200);
    await shoot(t, '11-library');
    await tap(t, find.byKey(const Key('open-filter')), 1000);
    await tap(t, find.byKey(const Key('skill-blending')), 300);
    await tap(t, find.byKey(const Key('len-medium')), 300);
    t
        .state<ScrollableState>(find.descendant(of: find.byType(FilterSheet), matching: find.byType(Scrollable)).first)
        .position
        .jumpTo(0);
    await settle(t, 300);
    await shoot(t, '12-library-filter');
    await tap(t, find.byKey(const Key('apply-filter')), 1000);

    router().push('/library/story-pip-hat');
    await settle(t, 1200);
    await shoot(t, '13-story-detail');
    router().pop();
    await settle(t, 600);

    router().go('/profile');
    await settle(t, 1000);
    await shoot(t, '14-parent-gate');
    await tap(t, find.byKey(const Key('gate-42')), 1000);
    await shoot(t, '15-profile');
  });
}
