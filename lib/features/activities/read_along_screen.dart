import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../audio/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/content.dart';
import '../../ui/widgets.dart';
import 'activity_host.dart';

/// Audio-paired passage: one recording + per-word timestamps drive the karaoke highlight.
/// Playback pauses at authored checkpoints so the parent can ask a question.
class ReadAlongView extends ConsumerStatefulWidget {
  final Activity activity;
  final ReadAlongPayload payload;
  final ActivityContext ctx;
  const ReadAlongView({
    super.key,
    required this.activity,
    required this.payload,
    required this.ctx,
  });

  @override
  ConsumerState<ReadAlongView> createState() => _ReadAlongViewState();
}

class _ReadAlongViewState extends ConsumerState<ReadAlongView> {
  static const speeds = [0.8, 1.0, 1.2];
  Duration position = Duration.zero;
  bool playing = false;
  double speed = 0.8;
  ParentPrompt? prompt;
  final shown = <int>{};
  StreamSubscription? _pos, _play;

  ReadAlongPayload get p => widget.payload;

  @override
  void initState() {
    super.initState();
    final audio = ref.read(audioServiceProvider);
    audio.loadPassage(p.audio);
    _pos = audio.passagePosition.listen(_onPosition);
    _play = audio.passagePlaying.listen(
      (v) => mounted ? setState(() => playing = v) : null,
    );
  }

  void _onPosition(Duration d) {
    if (!mounted) return;
    setState(() => position = d);
    final line = p.cursorAt(d).line;
    for (final pr in p.prompts) {
      // pause once the last word of the checkpoint line has been spoken
      final last = p.lines[pr.afterLine].last;
      if (!shown.contains(pr.afterLine) &&
          d >= last.end &&
          line >= pr.afterLine) {
        shown.add(pr.afterLine);
        ref.read(audioServiceProvider).pausePassage();
        setState(() => prompt = pr);
      }
    }
  }

  /// Lets screenshots and tests show the highlight at a given point without real playback.
  void jumpTo(Duration d) => _onPosition(d);

  @override
  void dispose() {
    _pos?.cancel();
    _play?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioServiceProvider);
    final cursor = p.cursorAt(position);
    final total = p.duration;
    return Column(
      children: [
        ActivityTopBar(
          label: widget.ctx.label,
          progress: widget.ctx.progress,
          onClose: widget.ctx.onClose,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              Row(
                children: [
                  CategoryChip(widget.activity.category, withIcon: true),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.activity.minutes} min together',
                    style: AppText.caption,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.activity.shortTitle,
                style: AppText.hero.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    'assets/images/photo-map-for-sam.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.mic,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'FOLLOW ALONG',
                          style: AppText.caption.copyWith(
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (var li = 0; li < p.lines.length; li++)
                      AnimatedContainer(
                        key: Key('line-$li'),
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: li == cursor.line
                              ? AppColors.accentTint
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Wrap(
                          spacing: 7,
                          runSpacing: 4,
                          children: [
                            for (var wi = 0; wi < p.lines[li].length; wi++)
                              Text(
                                p.lines[li][wi].text,
                                style: AppText.reading.copyWith(
                                  fontSize: 24,
                                  color: li == cursor.line
                                      ? AppColors.accentOnTint
                                      : (li < cursor.line
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary),
                                  fontWeight:
                                      li == cursor.line && wi == cursor.word
                                      ? FontWeight.w800
                                      : FontWeight.w400,
                                  decoration:
                                      li == cursor.line && wi == cursor.word
                                      ? TextDecoration.underline
                                      : null,
                                  decorationColor: AppColors.accentFill,
                                  decorationThickness: 2,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (prompt != null)
                ParentPromptCard(
                  key: const Key('prompt'),
                  label: 'PAUSE AND ASK',
                  text: prompt!.text,
                  trailing: GestureDetector(
                    key: const Key('got-it'),
                    onTap: () {
                      setState(() => prompt = null);
                      audio.playPassage(speed: speed);
                    },
                    child: Text(
                      'Got it, keep reading',
                      style: AppText.label.copyWith(
                        color: AppColors.accentFill,
                      ),
                    ),
                  ),
                )
              else
                const ParentPromptCard(
                  text:
                      'Read each line after the voice. Point under the glowing word.',
                ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            shown.clear();
                            audio.seekPassage(Duration.zero);
                            setState(() => position = Duration.zero);
                          },
                          icon: const Icon(LucideIcons.rotateCcw),
                        ),
                        const Spacer(),
                        TapTarget(
                          label: 'Play or pause',
                          key: const Key('play'),
                          onTap: () => playing
                              ? audio.pausePassage()
                              : audio.playPassage(speed: speed),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.accentFill,
                            child: Icon(
                              playing ? LucideIcons.pause : LucideIcons.play,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(
                              () => speed =
                                  speeds[(speeds.indexOf(speed) + 1) %
                                      speeds.length],
                            );
                            audio.setPassageSpeed(speed);
                          },
                          child: Pill(
                            '${speed}x',
                            bg: AppColors.surfaceAlt,
                            fg: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: total.inMilliseconds == 0
                            ? 0
                            : (position.inMilliseconds / total.inMilliseconds)
                                  .clamp(0, 1),
                        minHeight: 6,
                        backgroundColor: AppColors.accentTint,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.accentFill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(_fmt(position), style: AppText.caption),
                        const Spacer(),
                        Text(_fmt(total), style: AppText.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: FilledButton.icon(
            key: const Key('next'),
            onPressed: widget.ctx.onFinish,
            iconAlignment: IconAlignment.end,
            icon: const Icon(LucideIcons.arrowRight),
            label: const Text('Next'),
          ),
        ),
      ],
    );
  }
}
