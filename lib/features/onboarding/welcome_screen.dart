import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        'Hopscotch',
                        textAlign: TextAlign.center,
                        style: AppText.hero.copyWith(
                          fontSize: 26,
                          color: AppColors.accentFill,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/today'),
                      child: Text(
                        'Skip',
                        style: AppText.label.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset(
                          'assets/images/hero-parent-child.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 14,
                      child: Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.accentTint,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('assets/images/logo-mark.png'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Five minutes a day, reading together',
                textAlign: TextAlign.center,
                style: AppText.hero,
              ),
              const SizedBox(height: 12),
              Text(
                'Short, playful activities you and your child do side by side. No screen time alone.',
                textAlign: TextAlign.center,
                style: AppText.bodyText.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.accentFill,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  for (var i = 0; i < 2; i++)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('get-started'),
                onPressed: () => context.go('/setup'),
                child: const Text('Get started'),
              ),
              TextButton(
                onPressed: () => context.go('/today'),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  'I already have an account',
                  style: AppText.label.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
