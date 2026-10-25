import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../audio/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/content.dart';
import '../../ui/widgets.dart';
import 'activity_host.dart';

/// Meet a letter: tap the big letter to hear its sound, then the example words.
class LetterSoundView extends ConsumerWidget {
  final Activity activity;
  final LetterSoundPayload payload;
  final ActivityContext ctx;
  const LetterSoundView({
    super.key,
    required this.activity,
    required this.payload,
    required this.ctx,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioServiceProvider);
    return Column(
      children: [
        ActivityTopBar(
          label: ctx.label,
          progress: ctx.progress,
          onClose: ctx.onClose,
        ),
        Expanded(
          child: ValueListenableBuilder<String?>(
            valueListenable: audio.nowPlaying,
            builder: (context, playing, _) => ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CategoryChip(activity.category, withIcon: true),
                ),
                const SizedBox(height: 12),
                Text(
                  'Say it with me',
                  style: AppText.hero.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TapTarget(
                    label: 'Hear the letter sound',
                    key: const Key('letter'),
                    onTap: () =>
                        audio.playClip(payload.letterAudio, key: 'letter'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(
                              alpha: playing == 'letter' ? 0.6 : 0.25,
                            ),
                            blurRadius: playing == 'letter' ? 36 : 20,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        payload.letter,
                        style: AppText.hero.copyWith(
                          fontSize: 110,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Tap the letter to hear its sound',
                    style: AppText.caption,
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader('Words with ${payload.letter}'),
                for (final w in payload.words)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => audio.playClip(w.audio, key: w.text),
                      border: Border.all(
                        color: playing == w.text
                            ? AppColors.accentFill
                            : AppColors.border,
                        width: playing == w.text ? 2 : 1,
                      ),
                      child: Row(
                        children: [
                          Text(
                            w.text,
                            style: AppText.reading.copyWith(fontSize: 26),
                          ),
                          const Spacer(),
                          const Icon(
                            LucideIcons.volume2,
                            color: AppColors.accentFill,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                ParentPromptCard(text: payload.parentPrompt),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: FilledButton.icon(
            key: const Key('next'),
            onPressed: ctx.onFinish,
            iconAlignment: IconAlignment.end,
            icon: const Icon(LucideIcons.arrowRight),
            label: const Text('Next'),
          ),
        ),
      ],
    );
  }
}
