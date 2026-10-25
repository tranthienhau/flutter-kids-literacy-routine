import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../state/providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  static const _icons = {
    'stories': LucideIcons.bookOpen,
    'sounds': LucideIcons.volume2,
    'streak': LucideIcons.flame,
    'words': LucideIcons.sparkles,
    'rhymes': LucideIcons.music,
    'minutes': LucideIcons.clock,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value!;
    final stats = ref.watch(statsProvider);
    final earned = catalog.achievements.where(stats.earned).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 20, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.go('/progress'),
              icon: const Icon(LucideIcons.chevronLeft, size: 28),
            ),
            Text('Achievements', style: AppText.hero.copyWith(fontSize: 26)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 16),
          child: Text(
            '$earned of ${catalog.achievements.length} earned',
            style: AppText.bodyText.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
            children: [
              for (final a in catalog.achievements)
                Builder(
                  builder: (context) {
                    final got = stats.earned(a);
                    final p = stats.achievementProgress(a);
                    return Column(
                      children: [
                        SizedBox(
                          width: 88,
                          height: 88,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (!got)
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value: p,
                                    strokeWidth: 4,
                                    backgroundColor: AppColors.border,
                                    valueColor: const AlwaysStoppedAnimation(
                                      AppColors.support,
                                    ),
                                  ),
                                ),
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: got ? AppColors.heroGradient : null,
                                  color: got ? null : AppColors.surfaceAlt,
                                  boxShadow: got
                                      ? [
                                          BoxShadow(
                                            color: AppColors.accentFill
                                                .withValues(alpha: 0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  got
                                      ? (_icons[a.metric] ?? LucideIcons.award)
                                      : LucideIcons.lock,
                                  color: got
                                      ? Colors.white
                                      : AppColors.textTertiary,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: AppText.caption.copyWith(
                            color: got
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
