import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  String? _currentlyPlayingUrl;
  
  /// Global notifier for audio-related errors
  static final ValueNotifier<String?> errorNotifier = ValueNotifier(null);

  void init() {
    _player.onLog.listen((msg) {
      debugPrint("AudioPlayer Log: $msg");
      if (msg.toLowerCase().contains("error")) {
        errorNotifier.value = "Playback error: Check your connection.";
      }
    });

    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _currentlyPlayingUrl = null;
      }
    });
  }

  String? get currentlyPlayingUrl => _currentlyPlayingUrl;

  Stream<Duration> get onPositionChanged => _player.onPositionChanged;
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  Future<void> play(String url) async {
    debugPrint("AudioService: Attempting to play $url");
    errorNotifier.value = null; // Reset previous errors
    
    try {
      _currentlyPlayingUrl = url;
      await _player.stop();
      await _player.play(UrlSource(url));
      debugPrint("AudioService: Play command sent successfully");
    } catch (e) {
      debugPrint("AudioService Error playing audio: $e");
      errorNotifier.value = "Unable to load audio. Please try again.";
      _currentlyPlayingUrl = null;
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.resume();
  }

  Future<void> stop() async {
    debugPrint("AudioService: Stopping playback");
    _currentlyPlayingUrl = null;
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

}
