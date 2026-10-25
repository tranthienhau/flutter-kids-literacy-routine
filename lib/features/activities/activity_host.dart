import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../audio/audio_service.dart';
import '../../data/models/content.dart';
import '../../state/providers.dart';
import 'letter_sound_screen.dart';
import 'read_along_screen.dart';
import 'storybook_screen.dart';
import 'tap_words_screen.dart';

/// Shared frame for every activity: resolves the activity from the catalog, works out its
/// step in today's routine and renders the screen for its content type.
class ActivityHost extends ConsumerWidget {
  final String id;
  const ActivityHost({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value;
    if (catalog == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final activity = catalog.byId(id);
    final routine = ref.watch(routineProvider) ?? const [];
    final idx = routine.indexWhere((a) => a.id == id);
    final ctx = ActivityContext(
      label: idx >= 0
          ? 'Step ${idx + 1} of ${routine.length}'
          : activity.shortTitle,
      progress: idx >= 0 ? (idx + 1) / routine.length : 0.5,
      onClose: () {
        ref.read(audioServiceProvider).stopAll();
        context.pop();
      },
      onFinish: () {
        ref.read(audioServiceProvider).stopAll();
        ref.read(progressProvider.notifier).complete(activity);
        context.pushReplacement('/complete/${activity.id}');
      },
    );
    return Scaffold(
      body: SafeArea(
        child: switch (activity.payload) {
          LetterSoundPayload p => LetterSoundView(
            activity: activity,
            payload: p,
            ctx: ctx,
          ),
          TapWordsPayload p => TapWordsView(
            activity: activity,
            payload: p,
            ctx: ctx,
          ),
          ReadAlongPayload p => ReadAlongView(
            activity: activity,
            payload: p,
            ctx: ctx,
          ),
          StorybookPayload p => StorybookView(
            activity: activity,
            payload: p,
            ctx: ctx,
          ),
        },
      ),
    );
  }
}

class ActivityContext {
  final String label;
  final double progress;
  final VoidCallback onClose;
  final VoidCallback onFinish;
  const ActivityContext({
    required this.label,
    required this.progress,
    required this.onClose,
    required this.onFinish,
  });
}
