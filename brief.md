# Hopscotch - Source Brief

## Title
Hopscotch - Read Together

## Description
Hopscotch gives parents a simple daily routine for teaching young children (ages 3 to 7) foundational reading skills at home. Each day the app serves a few short activities, each a few minutes long, that parent and child complete side by side: hearing letter sounds, tapping words to hear and break them into sounds, reading a passage along with narration, and sharing an illustrated storybook. The parent gets a coaching tip at every step, and the child sees a streak, skill progress and badges that grow as they read.

## Store links
Not yet published (proof-of-concept build).

## Platform
Both (iOS and Android, one Flutter codebase, Android-first).

## Category
Education / Kids (early literacy, parent and child co-reading).

## Features
- Personalized daily homepage with a routine picked for the child's reading stage
- Letter sound lessons with tap-to-hear letters and example words
- Interactive text: tap a highlighted word to hear it, then tap each letter to hear its sound
- Audio-paired reading passages with a word-by-word highlight, speed control and pause-and-ask prompts for the parent
- Paginated illustrated storybook with read-aloud narration, target words and a coaching tip per page
- Celebration screen with new words and time after each activity
- Progress dashboard: day streak with week view, minutes, words learned, stories, per-category skill bars, next milestone
- 12 achievement milestones with progress rings
- Content library with search, category tabs and filters (skill, length, level, hide finished)
- Child profile setup (name, age, avatar, reading stage, reminder time)
- Parent area behind a parent gate: reminders, reading voice, playback speed, offline download, privacy

## Tech stack
- Flutter (Dart), Material 3 with custom design tokens
- Riverpod for state, go_router with a stateful tab shell
- just_audio for word, phoneme, passage and page playback
- Structured content catalog (JSON) with a Firestore repository behind the same interface
- Python content pipeline producing AAC clips and per-word timestamps
- integration_test for real screenshot capture, flutter_test unit tests

## Industry
Early childhood education, family learning.

## Metrics
Unpublished proof of concept, no store metrics. Scope: 15 screens, 8 content-driven activities across 4 activity types, 12 achievement rules.

## Research notes
- Verified: all screens run on the iOS simulator and Android emulator from one codebase; audio playback, word timestamps and progress math are exercised by the capture run and unit tests.
- Mocked: narration is a synthetic stand-in voice for studio recordings; the child profile and five days of history are demo data; content is bundled JSON rather than a live Firestore project.
- Future expansion: Firestore and Cloud Storage content with an import tool for lesson editors, offline caching of audio and images, multiple child profiles, Lottie or Rive animated segments inside lessons, parent account sign-in.
