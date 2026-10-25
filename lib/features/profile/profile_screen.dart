import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/progress.dart';
import '../../state/providers.dart';
import '../../ui/widgets.dart';

/// Parent area. Locked behind a simple adult question so children cannot change settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(parentGateProvider);
    return unlocked ? const _ParentArea() : const _ParentGate();
  }
}

class _ParentGate extends ConsumerStatefulWidget {
  const _ParentGate();
  @override
  ConsumerState<_ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends ConsumerState<_ParentGate> {
  final a = 7, b = 6;
  late final List<int> options = ([a * b, a * b + 6, a * b - 4, a * b + 12]
    ..shuffle(Random(4)));
  bool wrong = false;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
    children: [
      const Center(
        child: CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.supportTint,
          child: Icon(
            LucideIcons.shieldCheck,
            size: 40,
            color: AppColors.supportOnTint,
          ),
        ),
      ),
      const SizedBox(height: 18),
      Text('Grown-ups only', textAlign: TextAlign.center, style: AppText.hero),
      const SizedBox(height: 8),
      Text(
        'Answer to open settings for the parent area.',
        textAlign: TextAlign.center,
        style: AppText.bodyText.copyWith(color: AppColors.textSecondary),
      ),
      const SizedBox(height: 24),
      AppCard(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Text(
              'What is $a x $b?',
              style: AppText.hero.copyWith(fontSize: 30),
            ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.4,
              children: [
                for (final o in options)
                  OutlinedButton(
                    key: Key('gate-$o'),
                    onPressed: () {
                      if (o == a * b) {
                        ref.read(parentGateProvider.notifier).unlock();
                      } else {
                        setState(() => wrong = true);
                      }
                    },
                    child: Text('$o', style: AppText.title),
                  ),
              ],
            ),
            if (wrong) ...[
              const SizedBox(height: 12),
              Text(
                'Not quite. Ask a grown-up to help.',
                style: AppText.caption.copyWith(color: const Color(0xFFA75906)),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

class _ParentArea extends ConsumerStatefulWidget {
  const _ParentArea();
  @override
  ConsumerState<_ParentArea> createState() => _ParentAreaState();
}

class _ParentAreaState extends ConsumerState<_ParentArea> {
  bool offline = true;
  double speed = 0.8;

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(childProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(
          children: [
            Expanded(child: Text('Profile', style: AppText.hero)),
            const Pill(
              'Parent area - unlocked',
              icon: LucideIcons.lockOpen,
              bg: AppColors.supportTint,
              fg: AppColors.supportOnTint,
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Row(
            children: [
              Avatar(child.avatar, size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: AppText.hero.copyWith(fontSize: 24),
                    ),
                    Text(
                      'Age ${child.age} - ${child.stage.label}',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.go('/setup'),
                child: Text(
                  'Edit',
                  style: AppText.label.copyWith(color: AppColors.accentFill),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.accentTint,
                child: Icon(LucideIcons.plus, color: AppColors.accentFill),
              ),
              const SizedBox(width: 14),
              Text(
                'Add another child',
                style: AppText.label.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Settings'),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              _row(
                LucideIcons.bell,
                'Daily reminder',
                trailing: Text('7:00 PM', style: AppText.caption),
              ),
              _row(
                LucideIcons.mic,
                'Reading voice',
                trailing: Text('Warm narrator', style: AppText.caption),
              ),
              _row(
                LucideIcons.gauge,
                'Playback speed',
                trailing: GestureDetector(
                  onTap: () => setState(() => speed = speed == 0.8 ? 1.0 : 0.8),
                  child: Pill(
                    '${speed}x',
                    bg: AppColors.surfaceAlt,
                    fg: AppColors.textPrimary,
                  ),
                ),
              ),
              _row(
                LucideIcons.download,
                'Download for offline',
                subtitle:
                    'Wi-Fi only - audio and pictures saved on this device',
                trailing: Switch(
                  value: offline,
                  activeTrackColor: AppColors.accentFill,
                  onChanged: (v) => setState(() => offline = v),
                ),
              ),
              _row(
                LucideIcons.shieldCheck,
                'Privacy and data',
                subtitle: 'No ads. No tracking on child screens.',
              ),
              _row(LucideIcons.circleHelp, 'Help and tips', last: true),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Center(child: Text('jenna.parker@email.com', style: AppText.caption)),
        const SizedBox(height: 6),
        Center(
          child: TextButton.icon(
            onPressed: () => ref.read(parentGateProvider.notifier).lock(),
            icon: const Icon(
              LucideIcons.lock,
              size: 18,
              color: AppColors.accentFill,
            ),
            label: Text(
              'Lock parent area',
              style: AppText.label.copyWith(color: AppColors.accentFill),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(
    IconData icon,
    String title, {
    String? subtitle,
    Widget? trailing,
    bool last = false,
  }) => Container(
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: AppColors.border)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Icon(icon, color: AppColors.accentFill, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.label.copyWith(fontSize: 16)),
              if (subtitle != null) Text(subtitle, style: AppText.caption),
            ],
          ),
        ),
        trailing ??
            const Icon(
              LucideIcons.chevronRight,
              color: AppColors.textSecondary,
            ),
      ],
    ),
  );
}
