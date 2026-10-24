/// Structured content models. Every screen renders from these, never from hardcoded copy,
/// so adding a lesson is a data change (catalog.json locally, Firestore in production).
library;

enum ActivityType { letterSound, tapWords, readAlong, storybook }

ActivityType _type(String s) =>
    ActivityType.values.firstWhere((t) => t.name == s);

class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final String category;
  final int minutes;
  final int level;
  final List<String> skills;
  final String cover;
  final bool isNew;
  final String summary;
  final ActivityPayload payload;

  const Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.category,
    required this.minutes,
    required this.level,
    required this.skills,
    required this.cover,
    required this.isNew,
    required this.summary,
    required this.payload,
  });

  factory Activity.fromJson(Map<String, dynamic> j) {
    final type = _type(j['type'] as String);
    final p = j['payload'] as Map<String, dynamic>;
    return Activity(
      id: j['id'] as String,
      type: type,
      title: j['title'] as String,
      category: j['category'] as String,
      minutes: j['minutes'] as int,
      level: j['level'] as int,
      skills: (j['skills'] as List).cast<String>(),
      cover: j['cover'] as String,
      isNew: j['isNew'] as bool? ?? false,
      summary: j['summary'] as String? ?? '',
      payload: switch (type) {
        ActivityType.letterSound => LetterSoundPayload.fromJson(p),
        ActivityType.tapWords => TapWordsPayload.fromJson(p),
        ActivityType.readAlong => ReadAlongPayload.fromJson(p),
        ActivityType.storybook => StorybookPayload.fromJson(p),
      },
    );
  }

  /// Short display name without the routine prefix ("Story time: Pip Finds a Hat" -> "Pip Finds a Hat").
  String get shortTitle =>
      title.contains(': ') ? title.split(': ').last : title;
}

sealed class ActivityPayload {
  const ActivityPayload();
}

class AudioWord {
  final String text;
  final String audio;
  const AudioWord(this.text, this.audio);
  factory AudioWord.fromJson(Map<String, dynamic> j) =>
      AudioWord(j['text'] as String, j['audio'] as String);
}

class LetterSoundPayload extends ActivityPayload {
  final String letter;
  final String letterAudio;
  final List<AudioWord> words;
  final String parentPrompt;
  const LetterSoundPayload(
    this.letter,
    this.letterAudio,
    this.words,
    this.parentPrompt,
  );
  factory LetterSoundPayload.fromJson(Map<String, dynamic> j) =>
      LetterSoundPayload(
        j['letter'] as String,
        j['letterAudio'] as String,
        (j['words'] as List)
            .map((w) => AudioWord.fromJson(w as Map<String, dynamic>))
            .toList(),
        j['parentPrompt'] as String,
      );
}

class Phoneme {
  final String grapheme;
  final String audio;
  const Phoneme(this.grapheme, this.audio);
}

class WordToken {
  final String text;
  final String? audio;
  final List<Phoneme> phonemes;
  const WordToken(this.text, this.audio, this.phonemes);
  bool get tappable => audio != null;
  factory WordToken.fromJson(Map<String, dynamic> j) => WordToken(
    j['text'] as String,
    j['audio'] as String?,
    ((j['phonemes'] as List?) ?? const [])
        .map(
          (p) =>
              Phoneme((p as Map)['grapheme'] as String, p['audio'] as String),
        )
        .toList(),
  );
}

class TapWordsPayload extends ActivityPayload {
  final List<WordToken> tokens;
  final String sentenceAudio;
  final String parentPrompt;
  const TapWordsPayload(this.tokens, this.sentenceAudio, this.parentPrompt);
  factory TapWordsPayload.fromJson(Map<String, dynamic> j) => TapWordsPayload(
    (j['tokens'] as List)
        .map((t) => WordToken.fromJson(t as Map<String, dynamic>))
        .toList(),
    j['sentenceAudio'] as String,
    j['parentPrompt'] as String,
  );
}

class TimedWord {
  final String text;
  final Duration start;
  final Duration end;
  const TimedWord(this.text, this.start, this.end);
}

class ParentPrompt {
  final int afterLine;
  final String text;
  const ParentPrompt(this.afterLine, this.text);
}

class ReadAlongPayload extends ActivityPayload {
  final String audio;
  final Duration duration;
  final List<List<TimedWord>> lines;
  final List<ParentPrompt> prompts;
  const ReadAlongPayload(this.audio, this.duration, this.lines, this.prompts);
  factory ReadAlongPayload.fromJson(Map<String, dynamic> j) => ReadAlongPayload(
    j['audio'] as String,
    Duration(milliseconds: j['durationMs'] as int),
    (j['lines'] as List)
        .map(
          (l) => ((l as Map)['words'] as List)
              .map(
                (w) => TimedWord(
                  (w as Map)['text'] as String,
                  Duration(milliseconds: w['startMs'] as int),
                  Duration(milliseconds: w['endMs'] as int),
                ),
              )
              .toList(),
        )
        .toList(),
    (j['prompts'] as List)
        .map(
          (p) =>
              ParentPrompt((p as Map)['afterLine'] as int, p['text'] as String),
        )
        .toList(),
  );

  /// Line index whose words cover [position], or -1 before the first word.
  ({int line, int word}) cursorAt(Duration position) {
    for (var li = 0; li < lines.length; li++) {
      for (var wi = 0; wi < lines[li].length; wi++) {
        final w = lines[li][wi];
        if (position < w.end + const Duration(milliseconds: 140)) {
          return position < w.start && li == 0 && wi == 0
              ? (line: -1, word: -1)
              : (line: li, word: wi);
        }
      }
    }
    return (line: lines.length - 1, word: lines.last.length - 1);
  }
}

class StoryPage {
  final String image;
  final String text;
  final List<String> highlight;
  final String coachTip;
  final String audio;
  const StoryPage(
    this.image,
    this.text,
    this.highlight,
    this.coachTip,
    this.audio,
  );
}

class StorybookPayload extends ActivityPayload {
  final List<String> wordsToListenFor;
  final String beforeYouRead;
  final List<StoryPage> pages;
  const StorybookPayload(this.wordsToListenFor, this.beforeYouRead, this.pages);
  factory StorybookPayload.fromJson(Map<String, dynamic> j) => StorybookPayload(
    (j['wordsToListenFor'] as List).cast<String>(),
    j['beforeYouRead'] as String,
    (j['pages'] as List).map((p) {
      final m = p as Map<String, dynamic>;
      return StoryPage(
        m['image'] as String,
        m['text'] as String,
        (m['highlight'] as List).cast<String>(),
        m['coachTip'] as String,
        m['audio'] as String,
      );
    }).toList(),
  );
}

class AchievementDef {
  final String id;
  final String title;
  final String metric;
  final int target;
  const AchievementDef(this.id, this.title, this.metric, this.target);
  factory AchievementDef.fromJson(Map<String, dynamic> j) {
    final rule = (j['rule'] as Map).cast<String, int>();
    return AchievementDef(
      j['id'] as String,
      j['title'] as String,
      rule.keys.first,
      rule.values.first,
    );
  }
}

class Catalog {
  final List<Activity> activities;
  final Map<String, List<String>> routines;
  final List<AchievementDef> achievements;
  const Catalog(this.activities, this.routines, this.achievements);

  factory Catalog.fromJson(Map<String, dynamic> j) => Catalog(
    (j['activities'] as List)
        .map((a) => Activity.fromJson(a as Map<String, dynamic>))
        .toList(),
    (j['routines'] as Map).map(
      (k, v) => MapEntry(k as String, (v as List).cast<String>()),
    ),
    (j['achievements'] as List)
        .map((a) => AchievementDef.fromJson(a as Map<String, dynamic>))
        .toList(),
  );

  Activity byId(String id) => activities.firstWhere((a) => a.id == id);
}
