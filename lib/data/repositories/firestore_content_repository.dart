import '../models/content.dart';
import 'content_repository.dart';

/// Production content source (Firestore + Cloud Storage).
///
/// Collections mirror catalog.json 1:1, so the same parser is reused:
///   activities/{activityId}        -> Activity.fromJson (payload embedded)
///   routines/{stageKey}            -> { activityIds: [...] }
///   achievements/{achievementId}   -> AchievementDef.fromJson
/// Audio and images live in Cloud Storage; documents store `gs://` paths that the
/// media layer resolves and caches on device for offline sessions.
///
/// Not wired in the prototype (no Firebase project), kept to show the seam:
///   final repo = FirestoreContentRepository(fetch: (path) => firestore.collection(path).get()...);
class FirestoreContentRepository implements ContentRepository {
  final Future<List<Map<String, dynamic>>> Function(String collection) fetch;
  FirestoreContentRepository({required this.fetch});

  @override
  Future<Catalog> loadCatalog() async {
    final activities = await fetch('activities');
    final routines = await fetch('routines');
    final achievements = await fetch('achievements');
    return Catalog.fromJson({
      'activities': activities,
      'routines': {
        for (final r in routines) r['id'] as String: r['activityIds'],
      },
      'achievements': achievements,
    });
  }
}
