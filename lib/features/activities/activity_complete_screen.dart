import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../state/providers.dart';
import '../../ui/widgets.dart';

class ActivityCompleteScreen extends ConsumerWidget {
  final String id;
  const ActivityCompleteScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value!;
    final activity = catalog.byId(id);
    final child = ref.watch(childProvider);
    final stats = ref.watch(statsProvider);
    final last = stats.state.sessions.lastWhere((s) => s.activityId == id);
    final routine = ref.watch(routineProvider) ?? const [];
    final done = stats.doneToday();
    final next = routine.where((a) => !done.contains(a.id)).firstOrNull;
    final badge = catalog.achievements.firstWhere(
      (a) => a.metric == activity.category,
      orElse: () => catalog.achievements.first,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.accentTint, AppColors.supportTint],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: AspectRatio(
                  aspectRatio: 1.15,
                  child: Image.asset(
                    'assets/images/celebrate-high-five.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Text(
                      'Great reading, ${child.name}!',
                      textAlign: TextAlign.center,
                      style: AppText.hero.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF5B400),
                          size: 44,
                        ),
                        Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF5B400),
                          size: 52,
                        ),
                        Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF5B400),
                          size: 44,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Stat(
                      icon: LucideIcons.sparkles,
                      label: 'New words',
                      value: last.newWords.join(', '),
                    ),
                    _Stat(
                      icon: LucideIcons.clock,
                      label: 'Time',
                      value: '${activity.minutes} min',
                    ),
                    const SizedBox(height: 12),
                    Pill(
                      'Badge progress: ${badge.title}',
                      icon: LucideIcons.award,
                      bg: AppColors.supportTint,
                      fg: AppColors.supportOnTint,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (next != null)
                FilledButton(
                  key: const Key('next-activity'),
                  onPressed: () =>
                      context.pushReplacement('/activity/${next.id}'),
                  child: const Text('Next activity'),
                )
              else
                FilledButton(
                  key: const Key('next-activity'),
                  onPressed: () => context.go('/today'),
                  child: const Text('Finish routine'),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('back-today'),
                style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () => context.go('/today'),
                child: const Text('Back to today'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Stat({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppColors.accentFill),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppText.label.copyWith(color: AppColors.textSecondary),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppText.label.copyWith(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
