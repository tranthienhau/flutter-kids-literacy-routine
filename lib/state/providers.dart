import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/content.dart';
import '../data/models/progress.dart';
import '../data/repositories/content_repository.dart';
import '../data/seed.dart';
import '../domain/progress_stats.dart';

/// Swap for FirestoreContentRepository in production via ProviderScope overrides.
final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => LocalContentRepository(),
);

final catalogProvider = FutureProvider<Catalog>(
  (ref) => ref.watch(contentRepositoryProvider).loadCatalog(),
);

/// Injectable clock so streaks and "today" are deterministic in tests and screenshots.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class ChildNotifier extends Notifier<ChildProfile> {
  @override
  ChildProfile build() => seedChild;
  void update(ChildProfile c) => state = c;
}

final childProvider = NotifierProvider<ChildNotifier, ChildProfile>(
  ChildNotifier.new,
);

class ProgressNotifier extends Notifier<ProgressState> {
  @override
  ProgressState build() => seedProgress(ref.read(clockProvider)());

  /// Records a finished activity and returns the words it introduced.
  List<String> complete(Activity a) {
    final words = switch (a.payload) {
      TapWordsPayload p =>
        p.tokens
            .where((t) => t.tappable)
            .map(
              (t) => t.text.replaceAll(RegExp('[^A-Za-z]'), '').toLowerCase(),
            )
            .toList(),
      LetterSoundPayload p => p.words.map((w) => w.text).toList(),
      StorybookPayload p => p.wordsToListenFor,
      ReadAlongPayload _ => const ['map', 'red', 'big'],
    };
    state = state.add(
      SessionRecord(
        a.id,
        a.category,
        ref.read(clockProvider)(),
        a.minutes,
        words,
      ),
    );
    return words;
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, ProgressState>(
  ProgressNotifier.new,
);

final statsProvider = Provider<ProgressStats>(
  (ref) =>
      ProgressStats(ref.watch(progressProvider), ref.watch(clockProvider)()),
);

/// Today's curated routine (null while the catalog loads).
final routineProvider = Provider<List<Activity>?>((ref) {
  final catalog = ref.watch(catalogProvider).value;
  if (catalog == null) return null;
  return RoutineBuilder.build(catalog, ref.watch(childProvider));
});

class LibraryFilter {
  final String category; // 'all' or a category key
  final Set<String> skills;
  final String length; // 'any' | 'short' | 'medium' | 'long'
  final int? level;
  final bool hideFinished;
  final String query;
  const LibraryFilter({
    this.category = 'all',
    this.skills = const {},
    this.length = 'any',
    this.level,
    this.hideFinished = false,
    this.query = '',
  });

  int get activeCount =>
      skills.length +
      (length != 'any' ? 1 : 0) +
      (level != null ? 1 : 0) +
      (hideFinished ? 1 : 0);

  LibraryFilter copyWith({
    String? category,
    Set<String>? skills,
    String? length,
    int? Function()? level,
    bool? hideFinished,
    String? query,
  }) => LibraryFilter(
    category: category ?? this.category,
    skills: skills ?? this.skills,
    length: length ?? this.length,
    level: level != null ? level() : this.level,
    hideFinished: hideFinished ?? this.hideFinished,
    query: query ?? this.query,
  );

  bool matches(Activity a, Set<String> finished) {
    if (category != 'all' && a.category != category) return false;
    if (skills.isNotEmpty && !a.skills.any(skills.contains)) return false;
    if (level != null && a.level != level) return false;
    if (hideFinished && finished.contains(a.id)) return false;
    final ok = switch (length) {
      'short' => a.minutes < 3,
      'medium' => a.minutes >= 3 && a.minutes <= 5,
      'long' => a.minutes > 5,
      _ => true,
    };
    if (!ok) return false;
    if (query.isNotEmpty &&
        !a.title.toLowerCase().contains(query.toLowerCase())) {
      return false;
    }
    return true;
  }
}

class LibraryFilterNotifier extends Notifier<LibraryFilter> {
  @override
  LibraryFilter build() => const LibraryFilter();
  void set(LibraryFilter f) => state = f;
}

final libraryFilterProvider =
    NotifierProvider<LibraryFilterNotifier, LibraryFilter>(
      LibraryFilterNotifier.new,
    );

final libraryResultsProvider = Provider<List<Activity>>((ref) {
  final catalog = ref.watch(catalogProvider).value;
  if (catalog == null) return const [];
  final filter = ref.watch(libraryFilterProvider);
  final finished = ref.watch(statsProvider).doneToday();
  return catalog.activities.where((a) => filter.matches(a, finished)).toList();
});

/// Parent gate state: settings stay locked until an adult answers the gate question.
class ParentGateNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void unlock() => state = true;
  void lock() => state = false;
}

final parentGateProvider = NotifierProvider<ParentGateNotifier, bool>(
  ParentGateNotifier.new,
);
