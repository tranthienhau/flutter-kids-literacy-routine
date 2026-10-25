import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../audio/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/content.dart';
import '../../state/providers.dart';
import '../../ui/widgets.dart';

/// Detail page for any library item, built from the activity's structured payload.
class StoryDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const StoryDetailScreen({super.key, required this.id});
  @override
  ConsumerState<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends ConsumerState<StoryDetailScreen> {
  bool favorite = false;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider).value!;
    final a = catalog.byId(widget.id);
    final child = ref.watch(childProvider);
    final audio = ref.watch(audioServiceProvider);
    final (words, tip, pages, listenAudio) = switch (a.payload) {
      StorybookPayload p => (
        p.wordsToListenFor,
        p.beforeYouRead.replaceAll('Maya', child.name),
        '${p.pages.length} pages',
        p.pages.first.audio,
      ),
      TapWordsPayload p => (
        p.tokens
            .where((t) => t.tappable)
            .map((t) => t.text.replaceAll(RegExp('[^A-Za-z]'), ''))
            .toList(),
        p.parentPrompt,
        '1 sentence',
        p.sentenceAudio,
      ),
      LetterSoundPayload p => (
        p.words.map((w) => w.text).toList(),
        p.parentPrompt,
        '${p.words.length} words',
        p.letterAudio,
      ),
      ReadAlongPayload p => (
        const ['map', 'red', 'big', 'tree'],
        p.prompts.first.text,
        '${p.lines.length} lines',
        p.audio,
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  Row(
                    children: [
                      _Circle(
                        icon: LucideIcons.chevronLeft,
                        onTap: () => context.pop(),
                      ),
                      const Spacer(),
                      _Circle(
                        icon: LucideIcons.heart,
                        color: favorite
                            ? AppColors.accentFill
                            : AppColors.textPrimary,
                        onTap: () => setState(() => favorite = !favorite),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Image.asset(a.cover, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    a.shortTitle,
                    style: AppText.hero.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      CategoryChip(a.category, withIcon: true),
                      Pill(
                        'Level ${a.level}',
                        bg: AppColors.surfaceAlt,
                        fg: AppColors.textPrimary,
                      ),
                      Pill(
                        pages,
                        icon: LucideIcons.bookOpen,
                        bg: AppColors.surfaceAlt,
                        fg: AppColors.textPrimary,
                      ),
                      Pill(
                        '${a.minutes} min',
                        icon: LucideIcons.clock,
                        bg: AppColors.surfaceAlt,
                        fg: AppColors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    a.summary,
                    style: AppText.bodyText.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Words to listen for', style: AppText.title),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a word to practice the sound',
                    style: AppText.caption,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final w in words) Pill(w, icon: LucideIcons.volume2),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ParentPromptCard(label: 'BEFORE YOU READ', text: tip),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                children: [
                  FilledButton.icon(
                    key: const Key('start'),
                    onPressed: () => context.push('/activity/${a.id}'),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(LucideIcons.arrowRight),
                    label: Text(
                      a.type == ActivityType.storybook
                          ? 'Start reading'
                          : 'Start activity',
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () =>
                        audio.playClip(listenAudio, key: 'preview'),
                    icon: const Icon(
                      LucideIcons.headphones,
                      color: AppColors.accentFill,
                    ),
                    label: const Text('Listen first'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _Circle({
    required this.icon,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });
  @override
  Widget build(BuildContext context) => TapTarget(
    label: icon == LucideIcons.heart ? 'Favorite' : 'Back',
    onTap: onTap,
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: cardShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, color: color),
    ),
  );
}
