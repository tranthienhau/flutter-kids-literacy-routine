# Hopscotch - Read Together

A daily reading routine that a parent and a young child (ages 3 to 7) do side by side. Each day the app serves a short, curated set of activities: tap a word to hear its sounds, read a passage along with narration, and page through an illustrated storybook with a coaching tip for the parent on every page. Streaks, skill progress and achievements keep the habit going.

Built with Flutter and Riverpod. Every screen renders from structured content data, so new lessons are a data change, not a code change.

## Demo

| iOS | Android |
|---|---|
| ![iOS demo](screenshots/demo.gif) | ![Android demo](screenshots/demo-android.gif) |

Same codebase running on both platforms.

## Screenshots

| Welcome | Child setup | Today | Tap the words |
|---|---|---|---|
| ![Welcome](screenshots/01-welcome.png) | ![Child setup](screenshots/02-child-setup.png) | ![Today](screenshots/03-today.png) | ![Tap the words](screenshots/04-tap-words.png) |

| Activity complete | Read along | Storybook | All done |
|---|---|---|---|
| ![Activity complete](screenshots/05-activity-complete.png) | ![Read along](screenshots/06-read-along.png) | ![Storybook](screenshots/07-storybook.png) | ![All done](screenshots/08-today-done.png) |

| Progress | Achievements | Library | Filters |
|---|---|---|---|
| ![Progress](screenshots/09-progress.png) | ![Achievements](screenshots/10-achievements.png) | ![Library](screenshots/11-library.png) | ![Filters](screenshots/12-library-filter.png) |

| Story detail | Parent gate | Parent area |
|---|---|---|
| ![Story detail](screenshots/13-story-detail.png) | ![Parent gate](screenshots/14-parent-gate.png) | ![Parent area](screenshots/15-profile.png) |

## What it shows

- **Personalized daily homepage** - today's routine is picked from the catalog by the child's reading stage (just starting, blending, reading), with a progress ring and an "Up next" shortcut.
- **Tap-a-word audio** - highlighted words play their recording; the word then breaks into letter tiles, and each tile plays its individual sound.
- **Audio-paired reading** - one narration file per passage plus per-word timestamps drive a karaoke-style highlight. Playback pauses at authored checkpoints so the parent can ask a question. Speed control (0.8x, 1x, 1.2x).
- **Illustrated storybook** - paginated, swipeable pages with read-aloud narration, highlighted target words and a coaching tip per page.
- **Progress dashboard** - day streak with a week view, minutes, words learned, stories finished, per-category skill bars and the next milestone.
- **Achievements** - 12 milestones computed from the session log, with progress rings on locked badges.
- **Content library** - search, category tabs and a filter sheet (category, skill, length, level, hide finished).
- **Parent area behind a parent gate** - child profile, reminders, reading voice, playback speed, offline download and privacy settings. No ads and no tracking on child screens.

## Flow

```mermaid
flowchart TD
    A[Welcome] --> B[Child setup: name, age, reading stage]
    B --> C[Today: routine built for the stage]
    C -->|Continue| D{Activity type}
    D -->|letterSound| E[Letter sound]
    D -->|tapWords| F[Tap the words + letter tiles]
    D -->|readAlong| G[Read along with timed highlight]
    D -->|storybook| H[Storybook with coach tips]
    E & F & G & H --> I[Activity complete: new words, time]
    I -->|Next activity| D
    I -->|Back to today| C
    C -->|All activities done| J[All done for today]
    C --- K[Library: search + filters] --> L[Story detail] --> D
    C --- M[Progress: streak, skills] --> N[Achievements]
    C --- O[Profile] --> P{Parent gate}
    P -->|correct answer| Q[Parent area settings]
```

## Architecture

```
lib/
  app/            router (go_router, StatefulShellRoute tabs), shell, app
  core/theme/     design tokens: colors, category styles, type scale, radii
  data/
    models/       Activity + typed payloads (letterSound, tapWords, readAlong, storybook), progress
    repositories/ ContentRepository (bundled JSON) + Firestore implementation of the same interface
    seed.dart     demo child and five days of session history
  domain/         ProgressStats (streak, week, skills, achievements), RoutineBuilder - pure Dart, unit tested
  audio/          AudioService over just_audio: tap player for words/phonemes, passage player with position stream
  state/          Riverpod providers: catalog, child, progress, routine, library filter, parent gate
  features/       onboarding, today, activities, progress, library, profile
assets/
  content/catalog.json   structured lessons, routines and achievement rules
  audio/                 words, phonemes, sentences, passages, story pages (AAC)
tool/build_content.py    content pipeline: narration -> clips + word timestamps -> catalog.json
```

- **Content-driven rendering.** `Activity.fromJson` maps each catalog entry to a typed payload; `ActivityHost` picks the screen by payload type. Adding a story or a sound lesson only adds JSON and media.
- **Firestore-ready.** `catalog.json` mirrors the Firestore layout (`activities/`, `routines/`, `achievements/`) and `FirestoreContentRepository` reuses the same parser. Switching is a single provider override; media paths move to Cloud Storage.
- **Audio design.** Reading passages ship as one file with word timestamps instead of hundreds of tiny clips, which keeps taps responsive on Android and makes content upload simple. Short taps use a dedicated player so a new tap cuts the previous sound instantly.
- **Deterministic clock.** "Today", streaks and the greeting come from an injectable clock provider, which keeps tests and captures stable.

## Run

```sh
flutter pub get
flutter run            # iOS simulator or Android emulator
flutter test           # unit tests for streaks and read-along timing
```

Regenerate the content catalog and audio (macOS):

```sh
python3 tool/build_content.py
```
