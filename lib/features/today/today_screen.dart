import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/content.dart';
import '../../state/providers.dart';
import '../../ui/widgets.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routine = ref.watch(routineProvider);
    final child = ref.watch(childProvider);
    final stats = ref.watch(statsProvider);
    if (routine == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final done = stats.doneToday();
    final doneCount = routine.where((a) => done.contains(a.id)).length;
    final next = routine.where((a) => !done.contains(a.id)).firstOrNull;
    final hour = ref.watch(clockProvider)().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : (hour < 17 ? 'Good afternoon' : 'Good evening');

    final header = Row(
      children: [
        Avatar(child.avatar, size: 56),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'READING WITH',
                style: AppText.caption.copyWith(letterSpacing: 1),
              ),
              Text(
                '$greeting, ${child.name}',
                style: AppText.hero.copyWith(fontSize: 24),
              ),
            ],
          ),
        ),
        StreakChip(stats.streak),
      ],
    );

    if (next == null) {
      return _AllDone(
        header: header,
        name: child.name,
        minutes: stats.todaySessions.fold(0, (a, s) => a + s.minutes),
        words: stats.todaySessions.expand((s) => s.newWords).toSet().length,
        streak: stats.streak,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        header,
        const SizedBox(height: 20),
        GradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Pill(
                          'Daily routine',
                          icon: LucideIcons.sparkles,
                          bg: Color(0x33000000),
                          fg: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Today's routine",
                          style: AppText.hero.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${routine.length} activities - about ${routine.fold(0, (a, x) => a + x.minutes)} min',
                          style: AppText.bodyText.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: doneCount / routine.length,
                            strokeWidth: 6,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$doneCount/${routine.length}',
                              style: AppText.title.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'DONE',
                              style: AppText.caption.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 28),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Up next: ${next.shortTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.label.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    key: const Key('continue'),
                    onPressed: () => context.push('/activity/${next.id}'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.accentFill,
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(LucideIcons.arrowRight, size: 20),
                    label: const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SectionHeader(
          "${child.name}'s activities",
          trailing: 'Step ${doneCount + 1} of ${routine.length}',
        ),
        for (var i = 0; i < routine.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ActivityRow(
              index: i + 1,
              activity: routine[i],
              done: done.contains(routine[i].id),
              isNext: routine[i] == next,
            ),
          ),
        const SizedBox(height: 4),
        ParentPromptCard(
          text: 'Let ${child.name} tap first, then repeat the sound together.',
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final int index;
  final Activity activity;
  final bool done;
  final bool isNext;
  const _ActivityRow({
    required this.index,
    required this.activity,
    required this.done,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (activity.type) {
      ActivityType.letterSound => 'Hear it, say it, find it',
      ActivityType.tapWords => 'Phonics tap and sound out',
      ActivityType.readAlong => 'Side-by-side read together',
      ActivityType.storybook => 'Picture book with coaching',
    };
    return AppCard(
      onTap: () => context.push('/activity/${activity.id}'),
      padding: const EdgeInsets.all(12),
      border: Border.all(
        color: isNext ? AppColors.accentFill : AppColors.border,
        width: isNext ? 2 : 1,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(activity.cover, fit: BoxFit.cover),
                  if (done)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.success,
                          child: Icon(
                            LucideIcons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CategoryChip(activity.category),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text('${activity.minutes} min', style: AppText.caption),
                      ],
                    ),
                    if (isNext)
                      const Pill(
                        'NEXT',
                        bg: AppColors.accentFill,
                        fg: Colors.white,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$index. ${activity.shortTitle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                done
                    ? Row(
                        children: [
                          const Icon(
                            LucideIcons.circleCheck,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Completed today',
                            style: AppText.caption.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      )
                    : Text(subtitle, style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (done)
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.successTint,
              child: Icon(
                LucideIcons.check,
                color: AppColors.success,
                size: 20,
              ),
            )
          else if (isNext)
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.accentFill,
              child: Icon(LucideIcons.play, color: Colors.white, size: 20),
            )
          else
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surfaceAlt,
              child: Icon(
                LucideIcons.chevronRight,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class _AllDone extends StatelessWidget {
  final Widget header;
  final String name;
  final int minutes;
  final int words;
  final int streak;
  const _AllDone({
    required this.header,
    required this.name,
    required this.minutes,
    required this.words,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('all-done'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        header,
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AspectRatio(
            aspectRatio: 1.1,
            child: Image.asset(
              'assets/images/empty-all-done.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'All done for today!',
          textAlign: TextAlign.center,
          style: AppText.hero,
        ),
        const SizedBox(height: 8),
        Text(
          '$name finished every activity. Come back tomorrow to keep the $streak-day streak going.',
          textAlign: TextAlign.center,
          style: AppText.bodyText.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Pill('$minutes min read', icon: LucideIcons.clock),
            const SizedBox(width: 8),
            Pill(
              '$words new words',
              icon: LucideIcons.sparkles,
              bg: AppColors.supportTint,
              fg: AppColors.supportOnTint,
            ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.go('/library'),
          child: const Text('Read a bonus story'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.go('/progress'),
          child: const Text('See progress'),
        ),
      ],
    );
  }
}
