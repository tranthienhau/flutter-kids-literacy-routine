import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final BoxBorder? border;
  final VoidCallback? onTap;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: border ?? Border.all(color: AppColors.border),
        boxShadow: cardShadow,
      ),
      child: child,
    );
    if (onTap == null) return box;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: box,
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String category;
  final bool withIcon;
  const CategoryChip(this.category, {super.key, this.withIcon = false});

  @override
  Widget build(BuildContext context) {
    final s = CategoryStyle.of(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: s.tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withIcon) ...[
            Icon(s.icon, size: 16, color: s.onTint),
            const SizedBox(width: 6),
          ],
          Text(
            s.label,
            style: AppText.caption.copyWith(
              color: s.onTint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color bg;
  final Color fg;
  const Pill(
    this.text, {
    super.key,
    this.icon,
    this.bg = AppColors.accentTint,
    this.fg = AppColors.accentOnTint,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: AppText.caption.copyWith(
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

/// Lavender coaching card shown to the parent during every activity.
class ParentPromptCard extends StatelessWidget {
  final String label;
  final String text;
  final Widget? trailing;
  const ParentPromptCard({
    super.key,
    this.label = 'PARENT TIP',
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.supportTint,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: const Color(0xFFDCD3FC)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            LucideIcons.lightbulb,
            color: AppColors.supportOnTint,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppText.caption.copyWith(
                  color: AppColors.supportOnTint,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(text, style: AppText.bodyText.copyWith(fontSize: 15)),
              if (trailing != null) ...[const SizedBox(height: 6), trailing!],
            ],
          ),
        ),
      ],
    ),
  );
}

/// Header for activity screens: close X, step label and a thin progress bar.
class ActivityTopBar extends StatelessWidget {
  final String label;
  final double progress;
  final VoidCallback onClose;
  const ActivityTopBar({
    super.key,
    required this.label,
    required this.progress,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              key: const Key('close'),
              onPressed: onClose,
              icon: const Icon(LucideIcons.x, size: 26),
              tooltip: 'Close',
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppText.title.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.accentFill),
            ),
          ),
        ),
      ],
    ),
  );
}

class Avatar extends StatelessWidget {
  final String image;
  final double size;
  const Avatar(this.image, {super.key, this.size = 48});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: const EdgeInsets.all(2.5),
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: AppColors.heroGradient,
    ),
    child: Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: ClipOval(child: Image.asset(image, fit: BoxFit.cover)),
    ),
  );
}

class StreakChip extends StatelessWidget {
  final int days;
  const StreakChip(this.days, {super.key});
  @override
  Widget build(BuildContext context) =>
      Pill('$days days', icon: LucideIcons.flame);
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailing;
  const SectionHeader(this.title, {super.key, this.trailing, this.onTrailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: AppText.title.copyWith(fontSize: 22)),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailing,
            child: Text(
              trailing!,
              style: AppText.label.copyWith(
                color: onTrailing != null
                    ? AppColors.accentFill
                    : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    ),
  );
}

/// Pink tappable word with a speaker icon; pulses while its audio plays.
class WordPill extends StatelessWidget {
  final String text;
  final bool active;
  final double fontSize;
  final VoidCallback onTap;
  const WordPill({
    super.key,
    required this.text,
    required this.active,
    required this.onTap,
    this.fontSize = 32,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Hear $text',
    excludeSemantics: true,
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: fontSize * 0.45,
          vertical: fontSize * 0.26,
        ),
        decoration: BoxDecoration(
          color: AppColors.accentTint,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.accentFill : Colors.transparent,
            width: 3,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.45),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: AppText.reading.copyWith(
                fontSize: fontSize,
                color: AppColors.accentOnTint,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            SizedBox(width: fontSize * 0.2),
            Icon(
              LucideIcons.volume2,
              size: fontSize * 0.55,
              color: AppColors.accentOnTint,
            ),
          ],
        ),
      ),
    ),
  );
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const GradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      gradient: AppColors.heroGradient,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: AppColors.accentFill.withValues(alpha: 0.25),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}

/// GestureDetector with a screen reader label, for custom round and tile buttons.
class TapTarget extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget child;
  const TapTarget({
    super.key,
    required this.label,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    ),
  );
}
