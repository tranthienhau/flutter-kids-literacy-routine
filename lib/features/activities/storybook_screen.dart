import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../audio/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/content.dart';
import '../../ui/widgets.dart';
import 'activity_host.dart';

/// Paginated illustrated book. Each page carries its own narration and a coaching tip.
class StorybookView extends ConsumerStatefulWidget {
  final Activity activity;
  final StorybookPayload payload;
  final ActivityContext ctx;
  const StorybookView({
    super.key,
    required this.activity,
    required this.payload,
    required this.ctx,
  });

  @override
  ConsumerState<StorybookView> createState() => _StorybookViewState();
}

class _StorybookViewState extends ConsumerState<StorybookView> {
  final controller = PageController();
  int page = 0;
  bool readAloud = true;

  List<StoryPage> get pages => widget.payload.pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && readAloud) {
        ref
            .read(audioServiceProvider)
            .playClip(pages[0].audio, key: 'page-0', speed: 0.95);
      }
    });
  }

  void _go(int i) {
    if (i >= pages.length) {
      widget.ctx.onFinish();
      return;
    }
    controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _onPage(int i) {
    setState(() => page = i);
    if (readAloud) {
      ref
          .read(audioServiceProvider)
          .playClip(pages[i].audio, key: 'page-$i', speed: 0.95);
    }
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioServiceProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
          child: Row(
            children: [
              IconButton(
                key: const Key('close'),
                onPressed: widget.ctx.onClose,
                icon: const Icon(LucideIcons.x, size: 26),
              ),
              Expanded(
                child: Text(
                  widget.activity.shortTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.hero.copyWith(
                    fontSize: 22,
                    color: AppColors.accentFill,
                  ),
                ),
              ),
              Pill('Page ${page + 1} of ${pages.length}'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (page + 1) / pages.length,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.accentFill),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            key: const Key('pages'),
            controller: controller,
            itemCount: pages.length,
            onPageChanged: _onPage,
            itemBuilder: (context, i) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 1.15,
                      child: Image.asset(pages[i].image, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: ValueListenableBuilder<String?>(
                    valueListenable: audio.nowPlaying,
                    builder: (context, playing, _) => _PageText(
                      page: pages[i],
                      onWord: (w) =>
                          audio.playClip(pages[i].audio, key: 'page-$i'),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ParentPromptCard(label: 'COACH TIP', text: pages[i].coachTip),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Row(
            children: [
              _RoundButton(
                icon: readAloud ? LucideIcons.volume2 : LucideIcons.volumeX,
                onTap: () {
                  setState(() => readAloud = !readAloud);
                  if (readAloud) {
                    audio.playClip(pages[page].audio, key: 'page-$page');
                  }
                },
              ),
              const SizedBox(width: 12),
              _RoundButton(
                key: const Key('prev'),
                icon: LucideIcons.arrowLeft,
                onTap: page == 0 ? null : () => _go(page - 1),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < pages.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == page ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == page
                              ? AppColors.accentFill
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                  ],
                ),
              ),
              TapTarget(
                label: 'Next page',
                key: const Key('next-page'),
                onTap: () => _go(page + 1),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.accentFill,
                  child: Icon(
                    page == pages.length - 1
                        ? LucideIcons.check
                        : LucideIcons.arrowRight,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageText extends StatelessWidget {
  final StoryPage page;
  final void Function(String) onWord;
  const _PageText({required this.page, required this.onWord});

  @override
  Widget build(BuildContext context) {
    final words = page.text.split(' ');
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final w in words)
          page.highlight.contains(
                w.replaceAll(RegExp('[^A-Za-z]'), '').toLowerCase(),
              )
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    w,
                    style: AppText.reading.copyWith(
                      fontSize: 26,
                      color: AppColors.accentOnTint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Text(w, style: AppText.reading.copyWith(fontSize: 26)),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundButton({super.key, required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => TapTarget(
    label: icon == LucideIcons.arrowLeft ? 'Previous page' : 'Read aloud',
    onTap: onTap,
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: cardShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(
        icon,
        color: onTap == null ? AppColors.border : AppColors.textPrimary,
      ),
    ),
  );
}
