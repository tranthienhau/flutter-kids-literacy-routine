import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../audio/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/content.dart';
import '../../ui/widgets.dart';
import 'activity_host.dart';

/// Interactive text: tap a highlighted word to hear it, then tap its letters to hear each sound.
class TapWordsView extends ConsumerStatefulWidget {
  final Activity activity;
  final TapWordsPayload payload;
  final ActivityContext ctx;
  const TapWordsView({
    super.key,
    required this.activity,
    required this.payload,
    required this.ctx,
  });

  @override
  ConsumerState<TapWordsView> createState() => _TapWordsViewState();
}

class _TapWordsViewState extends ConsumerState<TapWordsView> {
  WordToken? selected;
  int? selectedPhoneme;

  @override
  void initState() {
    super.initState();
    selected = widget.payload.tokens.firstWhere((t) => t.tappable);
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioServiceProvider);
    final p = widget.payload;
    return Column(
      children: [
        ActivityTopBar(
          label: widget.ctx.label,
          progress: widget.ctx.progress,
          onClose: widget.ctx.onClose,
        ),
        Expanded(
          child: ValueListenableBuilder<String?>(
            valueListenable: audio.nowPlaying,
            builder: (context, playing, _) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CategoryChip(widget.activity.category, withIcon: true),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap a pink word to hear it',
                  style: AppText.hero.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 14,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final t in p.tokens)
                        t.tappable
                            ? WordPill(
                                key: Key(
                                  'word-${t.text.replaceAll(RegExp('[^A-Za-z]'), '').toLowerCase()}',
                                ),
                                text: t.text.replaceAll(
                                  RegExp('[^A-Za-z]'),
                                  '',
                                ),
                                active:
                                    playing == 'word-${t.text}' ||
                                    (playing == null && selected == t),
                                onTap: () {
                                  setState(() {
                                    selected = t;
                                    selectedPhoneme = null;
                                  });
                                  audio.playClip(
                                    t.audio!,
                                    key: 'word-${t.text}',
                                  );
                                },
                              )
                            : Text(
                                t.text,
                                style: AppText.reading.copyWith(fontSize: 32),
                              ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (selected != null) ...[
                  Row(
                    children: [
                      Text(
                        'Break it down',
                        style: AppText.label.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Pill('Sounds'),
                      const Spacer(),
                      const Icon(
                        LucideIcons.pointer,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text('Tap a letter', style: AppText.caption),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (var i = 0; i < selected!.phonemes.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(
                          child: _PhonemeTile(
                            key: Key('phoneme-$i'),
                            phoneme: selected!.phonemes[i],
                            active: selectedPhoneme == i,
                            onTap: () {
                              setState(() => selectedPhoneme = i);
                              audio.playClip(
                                selected!.phonemes[i].audio,
                                key: 'ph-$i',
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                ParentPromptCard(text: p.parentPrompt),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            children: [
              OutlinedButton.icon(
                key: const Key('hear-sentence'),
                onPressed: () => audio.playClip(
                  p.sentenceAudio,
                  key: 'sentence',
                  speed: 0.9,
                ),
                icon: const Icon(
                  LucideIcons.circlePlay,
                  color: AppColors.accentFill,
                ),
                label: const Text('Hear the whole sentence'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('next'),
                onPressed: widget.ctx.onFinish,
                iconAlignment: IconAlignment.end,
                icon: const Icon(LucideIcons.arrowRight),
                label: const Text('Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhonemeTile extends StatelessWidget {
  final Phoneme phoneme;
  final bool active;
  final VoidCallback onTap;
  const _PhonemeTile({
    super.key,
    required this.phoneme,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => TapTarget(
    label: 'Sound of ${phoneme.grapheme}',
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 96,
      decoration: BoxDecoration(
        color: active ? AppColors.accentTint : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(
          color: active ? AppColors.accentFill : AppColors.border,
          width: active ? 3 : 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            phoneme.grapheme,
            style: AppText.reading.copyWith(
              fontSize: 38,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.accentOnTint : AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Icon(
            active ? LucideIcons.volume2 : LucideIcons.volume1,
            size: 18,
            color: active ? AppColors.accentFill : AppColors.textSecondary,
          ),
        ],
      ),
    ),
  );
}
