import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../state/providers.dart';

Future<void> showFilterSheet(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  useRootNavigator: true,
  backgroundColor: Colors.transparent,
  barrierColor: AppColors.textPrimary.withValues(alpha: 0.45),
  builder: (_) => const FilterSheet(),
);

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});
  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  static const skills = {
    'letter-sounds': 'Letter sounds',
    'blending': 'Blending',
    'sight-words': 'Sight words',
    'rhyming': 'Rhyming',
  };
  static const lengths = {
    'short': 'Under 3 min',
    'medium': '3-5 min',
    'long': '5+ min',
  };
  late LibraryFilter f;

  @override
  void initState() {
    super.initState();
    f = ref.read(libraryFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider).value!;
    final finished = ref.watch(statsProvider).doneToday();
    final count = catalog.activities
        .where((a) => f.matches(a, finished))
        .length;
    return Material(
      color: AppColors.background,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            20 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text('Filter', style: AppText.hero.copyWith(fontSize: 26)),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        setState(() => f = LibraryFilter(query: f.query)),
                    child: Text(
                      'Reset',
                      style: AppText.label.copyWith(
                        color: AppColors.accentFill,
                      ),
                    ),
                  ),
                ],
              ),
              _label('Category'),
              _wrap([
                for (final k in ['all', ...CategoryStyle.keys])
                  _chip(
                    k == 'all' ? 'All' : CategoryStyle.of(k).label,
                    f.category == k,
                    () => setState(() => f = f.copyWith(category: k)),
                  ),
              ]),
              _label('Skill'),
              _wrap([
                for (final e in skills.entries)
                  _chip(e.value, f.skills.contains(e.key), () {
                    final s = {...f.skills};
                    s.contains(e.key) ? s.remove(e.key) : s.add(e.key);
                    setState(() => f = f.copyWith(skills: s));
                  }, key: 'skill-${e.key}'),
              ]),
              _label('Length'),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    for (final e in lengths.entries)
                      Expanded(
                        child: GestureDetector(
                          key: Key('len-${e.key}'),
                          onTap: () => setState(
                            () => f = f.copyWith(
                              length: f.length == e.key ? 'any' : e.key,
                            ),
                          ),
                          child: Container(
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: f.length == e.key
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: f.length == e.key ? cardShadow : null,
                            ),
                            child: Text(
                              e.value,
                              style: AppText.label.copyWith(
                                color: f.length == e.key
                                    ? AppColors.accentFill
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _label('Level'),
              _wrap([
                for (final l in [1, 2, 3])
                  _chip(
                    'Level $l',
                    f.level == l,
                    () => setState(
                      () =>
                          f = f.copyWith(level: () => f.level == l ? null : l),
                    ),
                  ),
              ]),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: f.hideFinished,
                activeTrackColor: AppColors.accentFill,
                title: Text(
                  'Hide finished today',
                  style: AppText.label.copyWith(fontSize: 16),
                ),
                onChanged: (v) =>
                    setState(() => f = f.copyWith(hideFinished: v)),
              ),
              const SizedBox(height: 8),
              FilledButton(
                key: const Key('apply-filter'),
                onPressed: () {
                  ref.read(libraryFilterProvider.notifier).set(f);
                  Navigator.pop(context);
                },
                child: Text('Show $count activities'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 8),
    child: Text(
      t,
      style: AppText.label.copyWith(color: AppColors.textSecondary),
    ),
  );
  Widget _wrap(List<Widget> c) => Wrap(spacing: 8, runSpacing: 8, children: c);

  Widget _chip(String text, bool selected, VoidCallback onTap, {String? key}) =>
      GestureDetector(
        key: key != null ? Key(key) : null,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentTint : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.accentFill : AppColors.borderStrong,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            text,
            style: AppText.label.copyWith(
              color: selected ? AppColors.accentOnTint : AppColors.textPrimary,
            ),
          ),
        ),
      );
}
