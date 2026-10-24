import 'package:flutter/material.dart';

/// Design tokens from the Hopscotch design system (design/DESIGN.md).
class AppColors {
  static const background = Color(0xFFFCF4F9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF8E9F2);
  static const accent = Color(0xFFFC69C3);
  static const accentFill = Color(0xFFCA047E);
  static const accentPressed = Color(0xFFC2037A);
  static const accentTint = Color(0xFFFEE3F3);
  static const accentOnTint = Color(0xFF8F0459);
  static const support = Color(0xFFB09EFA);
  static const supportStrong = Color(0xFF9880FA);
  static const supportTint = Color(0xFFEEE9FE);
  static const supportOnTint = Color(0xFF4B3A9C);
  static const textPrimary = Color(0xFF1F0C18);
  static const textSecondary = Color(0xFF5E4A57);
  static const textTertiary = Color(0xFF7A6673);
  static const border = Color(0xFFEED9E6);
  static const borderStrong = Color(0xFFB682AE);
  static const success = Color(0xFF0E7C3A);
  static const successTint = Color(0xFFE3F4E9);
  static const gradientStart = Color(0xFFCA047E);
  static const gradientEnd = Color(0xFF6A4FD8);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
}

/// One color pair per content category so chips, bars and badges stay consistent.
class CategoryStyle {
  final String label;
  final Color tint;
  final Color onTint;
  final Color bar;
  final IconData icon;
  const CategoryStyle(this.label, this.tint, this.onTint, this.bar, this.icon);

  static const _map = {
    'sounds': CategoryStyle(
      'Sounds',
      Color(0xFFFEE3F3),
      Color(0xFF8F0459),
      Color(0xFFCA047E),
      Icons.graphic_eq_rounded,
    ),
    'reading': CategoryStyle(
      'Reading',
      Color(0xFFEEE9FE),
      Color(0xFF4B3A9C),
      Color(0xFF9880FA),
      Icons.menu_book_rounded,
    ),
    'stories': CategoryStyle(
      'Stories',
      Color(0xFFFFEBDD),
      Color(0xFF8A3F00),
      Color(0xFFE87A2A),
      Icons.auto_stories_rounded,
    ),
    'rhymes': CategoryStyle(
      'Rhymes',
      Color(0xFFDDF5EA),
      Color(0xFF166534),
      Color(0xFF166534),
      Icons.music_note_rounded,
    ),
  };

  static CategoryStyle of(String key) => _map[key] ?? _map['sounds']!;
  static List<String> get keys => _map.keys.toList();
}

class AppText {
  static const display = 'Sniglet';
  static const body = 'VarelaRound';

  static const hero = TextStyle(
    fontFamily: display,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  static const title = TextStyle(
    fontFamily: body,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const bodyText = TextStyle(
    fontFamily: body,
    fontSize: 16,
    color: AppColors.textPrimary,
    height: 1.45,
  );
  static const label = TextStyle(
    fontFamily: body,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const caption = TextStyle(
    fontFamily: body,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static const reading = TextStyle(
    fontFamily: body,
    fontSize: 28,
    color: AppColors.textPrimary,
    height: 1.4,
  );
}

class AppRadius {
  static const card = 24.0;
  static const control = 16.0;
  static const input = 12.0;
}

const cardShadow = [
  BoxShadow(color: Color(0x0A1F0C18), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F1F0C18), blurRadius: 24, offset: Offset(0, 8)),
];

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: AppText.body,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accentFill,
      primary: AppColors.accentFill,
      secondary: AppColors.support,
      surface: AppColors.surface,
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: AppText.body,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accentFill,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: AppText.body,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontFamily: AppText.body, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.borderStrong),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.borderStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.accentFill, width: 2),
      ),
    ),
  );
}
