import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_theme.dart';

/// Bottom tab bar shared by the four primary sections (Today, Library, Progress, Profile).
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  static const tabs = [
    (LucideIcons.sun, 'Today'),
    (LucideIcons.bookOpen, 'Library'),
    (LucideIcons.trophy, 'Progress'),
    (LucideIcons.userRound, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(bottom: false, child: shell),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: InkWell(
                      key: Key('tab-${tabs[i].$2.toLowerCase()}'),
                      onTap: () => shell.goBranch(
                        i,
                        initialLocation: i == shell.currentIndex,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: i == shell.currentIndex
                                  ? AppColors.accentTint
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Icon(
                              tabs[i].$1,
                              color: i == shell.currentIndex
                                  ? AppColors.accentFill
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tabs[i].$2,
                            style: AppText.caption.copyWith(
                              fontSize: 13,
                              color: i == shell.currentIndex
                                  ? AppColors.accentFill
                                  : AppColors.textSecondary,
                              fontWeight: i == shell.currentIndex
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
