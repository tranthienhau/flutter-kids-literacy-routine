import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Thin wrapper over just_audio. One player for short taps (words, phonemes) so a new tap
/// cuts the previous sound instantly, and one for long passages with a position stream.
class AudioService {
  final _tap = AudioPlayer();
  final _passage = AudioPlayer();
  final nowPlaying = ValueNotifier<String?>(null);
  Timer? _clear;

  Future<void> playClip(String asset, {String? key, double speed = 1.0}) async {
    nowPlaying.value = key ?? asset;
    _clear?.cancel();
    try {
      await _tap.stop();
      final d = await _tap.setAsset(asset);
      await _tap.setSpeed(speed);
      unawaited(_tap.play());
      _clear = Timer(
        (d ?? const Duration(milliseconds: 700)) * (1 / speed) +
            const Duration(milliseconds: 250),
        () {
          if (nowPlaying.value == (key ?? asset)) nowPlaying.value = null;
        },
      );
    } catch (e) {
      debugPrint('audio: $e');
      _clear = Timer(
        const Duration(milliseconds: 800),
        () => nowPlaying.value = null,
      );
    }
  }

  Stream<Duration> get passagePosition => _passage.positionStream;
  Stream<bool> get passagePlaying => _passage.playingStream;

  Future<Duration?> loadPassage(String asset) async {
    try {
      return await _passage.setAsset(asset);
    } catch (e) {
      debugPrint('audio: $e');
      return null;
    }
  }

  Future<void> playPassage({double speed = 1.0}) async {
    await _passage.setSpeed(speed);
    if (_passage.processingState == ProcessingState.completed) {
      await _passage.seek(Duration.zero);
    }
    unawaited(_passage.play());
  }

  Future<void> pausePassage() => _passage.pause();
  Future<void> seekPassage(Duration d) => _passage.seek(d);
  Future<void> setPassageSpeed(double s) => _passage.setSpeed(s);

  Future<void> stopAll() async {
    await _tap.stop();
    await _passage.stop();
    nowPlaying.value = null;
  }

  void dispose() {
    _tap.dispose();
    _passage.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final s = AudioService();
  ref.onDispose(s.dispose);
  return s;
});
