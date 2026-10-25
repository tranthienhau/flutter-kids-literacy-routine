import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/content.dart';
import '../../state/providers.dart';
import '../../ui/widgets.dart';
import 'filter_sheet.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value;
    final filter = ref.watch(libraryFilterProvider);
    final results = ref.watch(libraryResultsProvider);
    final child = ref.watch(childProvider);
    if (catalog == null) return const SizedBox();
    final fresh = catalog.activities
        .where((a) => a.isNew || a.type == ActivityType.readAlong)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text('Library', style: AppText.hero),
        Text(
          "${child.name}'s collection (Age ${child.age})",
          style: AppText.bodyText.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('search'),
                onChanged: (q) => ref
                    .read(libraryFilterProvider.notifier)
                    .set(filter.copyWith(query: q)),
                style: AppText.bodyText,
                decoration: const InputDecoration(
                  hintText: 'Search stories, sounds, words',
                  prefixIcon: Icon(
                    LucideIcons.search,
                    color: AppColors.textSecondary,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            TapTarget(
              label: 'Filters',
              key: const Key('open-filter'),
              onTap: () => showFilterSheet(context),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: AppColors.borderStrong),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.slidersHorizontal,
                      color: AppColors.textPrimary,
                    ),
                    if (filter.activeCount > 0) ...[
                      const SizedBox(width: 6),
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: AppColors.accentFill,
                        child: Text(
                          '${filter.activeCount}',
                          style: AppText.caption.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final k in ['all', ...CategoryStyle.keys])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryTab(
                    k,
                    selected: filter.category == k,
                    onTap: () => ref
                        .read(libraryFilterProvider.notifier)
                        .set(filter.copyWith(category: k)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (filter.category == 'all' &&
            filter.query.isEmpty &&
            filter.activeCount == 0) ...[
          const SectionHeader('New this week'),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fresh.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => SizedBox(
                width: 260,
                child: _ContentCard(fresh[i], tall: true),
              ),
            ),
          ),
          const SizedBox(height: 22),
        ],
        SectionHeader('Explore', trailing: '${results.length} activities'),
        if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'No activities match these filters yet.',
              textAlign: TextAlign.center,
              style: AppText.bodyText.copyWith(color: AppColors.textSecondary),
            ),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.74,
          ),
          itemBuilder: (context, i) => _ContentCard(results[i]),
        ),
        const SizedBox(height: 16),
        ParentPromptCard(
          label: 'CO-READING TIP',
          text:
              'Ask ${child.name} to spot things starting with the letter m around your home after reading.',
        ),
      ],
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String k;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryTab(this.k, {required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final s = k == 'all' ? null : CategoryStyle.of(k);
    return GestureDetector(
      key: Key('cat-$k'),
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentFill
              : (s?.tint ?? AppColors.surfaceAlt),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          s?.label ?? 'All',
          style: AppText.label.copyWith(
            fontSize: 15,
            color: selected
                ? Colors.white
                : (s?.onTint ?? AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final Activity a;
  final bool tall;
  const _ContentCard(this.a, {this.tall = false});
  @override
  Widget build(BuildContext context) => AppCard(
    key: Key('content-${a.id}'),
    onTap: () => context.push('/library/${a.id}'),
    padding: const EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(a.cover, fit: BoxFit.cover),
                Positioned(left: 8, top: 8, child: CategoryChip(a.category)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          a.shortTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.label.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              '${a.minutes} min${tall && a.isNew ? ' - New' : ''}',
              style: AppText.caption,
            ),
            const Spacer(),
            Pill(
              'Level ${a.level}',
              bg: AppColors.surfaceAlt,
              fg: AppColors.textSecondary,
            ),
          ],
        ),
      ],
    ),
  );
}
