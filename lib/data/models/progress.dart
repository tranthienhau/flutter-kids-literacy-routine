enum ReadingStage { justStarting, blending, reading }

extension ReadingStageX on ReadingStage {
  String get key => switch (this) {
    ReadingStage.justStarting => 'just-starting',
    ReadingStage.blending => 'blending',
    ReadingStage.reading => 'reading',
  };
  String get label => switch (this) {
    ReadingStage.justStarting => 'Just starting',
    ReadingStage.blending => 'Blending',
    ReadingStage.reading => 'Reading',
  };
  String get description => switch (this) {
    ReadingStage.justStarting => 'Learning letter sounds',
    ReadingStage.blending => 'Sounding out short words',
    ReadingStage.reading => 'Simple sentences',
  };
}

class ChildProfile {
  final String name;
  final int age;
  final ReadingStage stage;
  final String avatar;
  const ChildProfile({
    required this.name,
    required this.age,
    required this.stage,
    required this.avatar,
  });

  ChildProfile copyWith({
    String? name,
    int? age,
    ReadingStage? stage,
    String? avatar,
  }) => ChildProfile(
    name: name ?? this.name,
    age: age ?? this.age,
    stage: stage ?? this.stage,
    avatar: avatar ?? this.avatar,
  );
}

/// One finished activity. Stored per child; in Firestore this is
/// `children/{childId}/sessions/{sessionId}`.
class SessionRecord {
  final String activityId;
  final String category;
  final DateTime day;
  final int minutes;
  final List<String> newWords;
  const SessionRecord(
    this.activityId,
    this.category,
    this.day,
    this.minutes,
    this.newWords,
  );
}

class ProgressState {
  final List<SessionRecord> sessions;
  final Map<String, int> baseSkill;
  const ProgressState({required this.sessions, required this.baseSkill});

  ProgressState add(SessionRecord r) =>
      ProgressState(sessions: [...sessions, r], baseSkill: baseSkill);
}
