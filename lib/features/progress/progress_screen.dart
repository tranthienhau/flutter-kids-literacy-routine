import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../state/providers.dart';
import '../../ui/widgets.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final child = ref.watch(childProvider);
    final catalog = ref.watch(catalogProvider).value;
    if (catalog == null) return const SizedBox();
    final week = stats.week;
    final todayIdx = stats.today.weekday - 1;
    final upcoming =
        catalog.achievements
            .where((a) => !stats.earned(a) && a.metric == 'streak')
            .firstOrNull ??
        catalog.achievements.firstWhere(
          (a) => !stats.earned(a),
          orElse: () => catalog.achievements.last,
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(
          children: [
            Avatar(child.avatar, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "${child.name}'s progress",
                style: AppText.hero.copyWith(fontSize: 26),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Pill(
                'Daily streak',
                icon: LucideIcons.flame,
                bg: Color(0x33000000),
                fg: Colors.white,
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${stats.streak}',
                    key: const Key('streak'),
                    style: AppText.hero.copyWith(
                      fontSize: 64,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'day streak!',
                      style: AppText.title.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${child.name} is on a roll. Read today to keep it going.',
                style: AppText.bodyText.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x33000000),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Column(
                        children: [
                          Text(
                            'MTWTFSS'[i],
                            style: AppText.caption.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: week[i]
                                  ? Colors.white
                                  : Colors.transparent,
                              border: Border.all(
                                color: Colors.white,
                                width: i == todayIdx ? 3 : 1.5,
                              ),
                            ),
                            child: week[i]
                                ? const Icon(
                                    LucideIcons.check,
                                    size: 18,
                                    color: AppColors.accentFill,
                                  )
                                : null,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _StatTile(
              icon: LucideIcons.clock,
              value: '${stats.minutesThisWeek}',
              label: 'Minutes\nthis week',
              color: AppColors.supportOnTint,
              tint: AppColors.supportTint,
            ),
            const SizedBox(width: 10),
            _StatTile(
              icon: LucideIcons.bookOpenText,
              value: '${stats.wordsLearned}',
              label: 'Words\nlearned',
              color: AppColors.accentOnTint,
              tint: AppColors.accentTint,
            ),
            const SizedBox(width: 10),
            _StatTile(
              icon: LucideIcons.bookOpen,
              value: '${stats.count('stories')}',
              label: 'Stories\nfinished',
              color: const Color(0xFF8A3F00),
              tint: const Color(0xFFFFEBDD),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionHeader('Skills', trailing: '4 areas'),
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              for (final k in CategoryStyle.keys)
                _SkillBar(category: k, value: stats.skill(k)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SectionHeader(
          'Next milestone',
          trailing: 'See all',
          onTrailing: () => context.go('/progress/achievements'),
        ),
        AppCard(
          onTap: () => context.go('/progress/achievements'),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentTint,
                  border: Border.all(color: AppColors.accentFill, width: 3),
                ),
                child: const Icon(
                  LucideIcons.flame,
                  color: AppColors.accentFill,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upcoming.title,
                      style: AppText.label.copyWith(fontSize: 17),
                    ),
                    Text(
                      '${upcoming.target - stats.metric(upcoming.metric)} to go',
                      style: AppText.caption,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: stats.achievementProgress(upcoming),
                        minHeight: 8,
                        backgroundColor: AppColors.accentTint,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.accentFill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.metric(upcoming.metric)} / ${upcoming.target}',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color tint;
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.tint,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: AppCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: tint,
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(value, style: AppText.hero.copyWith(fontSize: 30)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(color: color),
          ),
        ],
      ),
    ),
  );
}

class _SkillBar extends StatelessWidget {
  final String category;
  final double value;
  const _SkillBar({required this.category, required this.value});
  @override
  Widget build(BuildContext context) {
    final s = CategoryStyle.of(category);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: s.tint,
                child: Icon(s.icon, size: 18, color: s.onTint),
              ),
              const SizedBox(width: 10),
              Text(
                s.label,
                style: AppText.label.copyWith(fontSize: 17, color: s.onTint),
              ),
              const Spacer(),
              Text(
                '${(value * 100).round()}%',
                style: AppText.label.copyWith(fontSize: 16, color: s.onTint),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: s.tint,
              valueColor: AlwaysStoppedAnimation(s.bar),
            ),
          ),
        ],
      ),
    );
  }
}
