import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/progress.dart';
import '../../state/providers.dart';
import '../../ui/widgets.dart';

class ChildSetupScreen extends ConsumerStatefulWidget {
  const ChildSetupScreen({super.key});
  @override
  ConsumerState<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends ConsumerState<ChildSetupScreen> {
  static const avatars = [
    'assets/images/avatar-maya.jpg',
    'assets/images/avatar-boy-1.jpg',
    'assets/images/avatar-boy-2.jpg',
    'assets/images/avatar-girl-2.jpg',
  ];
  late final TextEditingController name;
  late int age;
  late ReadingStage stage;
  late String avatar;

  @override
  void initState() {
    super.initState();
    final c = ref.read(childProvider);
    name = TextEditingController(text: c.name);
    age = c.age;
    stage = c.stage;
    avatar = c.avatar;
  }

  @override
  Widget build(BuildContext context) {
    final childName = name.text.isEmpty ? 'your child' : name.text;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/welcome'),
                    icon: const Icon(LucideIcons.chevronLeft, size: 28),
                  ),
                  const Spacer(),
                  Text('Step 2 of 3', style: AppText.caption),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  Text(
                    'Who is reading with you?',
                    style: AppText.hero.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We use this to pick the right sounds and stories each day.',
                    style: AppText.bodyText.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final a in avatars)
                        GestureDetector(
                          onTap: () => setState(() => avatar = a),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: a == avatar
                                    ? AppColors.accentFill
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 32,
                              backgroundImage: AssetImage(a),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("Child's name", style: AppText.label),
                  const SizedBox(height: 8),
                  TextField(
                    controller: name,
                    style: AppText.bodyText,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  Text('Age', style: AppText.label),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final a in [3, 4, 5, 6, 7])
                        GestureDetector(
                          onTap: () => setState(() => age = a),
                          child: Container(
                            width: 56,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: a == age
                                  ? AppColors.accentFill
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppRadius.control,
                              ),
                              border: Border.all(
                                color: a == age
                                    ? AppColors.accentFill
                                    : AppColors.borderStrong,
                              ),
                            ),
                            child: Text(
                              '$a',
                              style: AppText.title.copyWith(
                                color: a == age
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Reading stage', style: AppText.label),
                  const SizedBox(height: 8),
                  for (final s in ReadingStage.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        onTap: () => setState(() => stage = s),
                        border: Border.all(
                          color: s == stage
                              ? AppColors.accentFill
                              : AppColors.border,
                          width: s == stage ? 2 : 1,
                        ),
                        color: s == stage
                            ? AppColors.accentTint
                            : AppColors.surface,
                        child: Row(
                          children: [
                            Icon(
                              s == stage
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: s == stage
                                  ? AppColors.accentFill
                                  : AppColors.borderStrong,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.label,
                                    style: AppText.label.copyWith(fontSize: 16),
                                  ),
                                  Text(s.description, style: AppText.caption),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  AppCard(
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.bell,
                          color: AppColors.accentFill,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Daily reminder',
                            style: AppText.label.copyWith(fontSize: 15),
                          ),
                        ),
                        Text('7:00 PM after dinner', style: AppText.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: FilledButton(
                key: const Key('build-routine'),
                onPressed: () {
                  ref
                      .read(childProvider.notifier)
                      .update(
                        ref
                            .read(childProvider)
                            .copyWith(
                              name: name.text,
                              age: age,
                              stage: stage,
                              avatar: avatar,
                            ),
                      );
                  context.go('/today');
                },
                child: Text("Build $childName's routine"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
