import 'dart:async';

import 'package:flutter/services.dart';

/// PCM format type
enum PCMType {
  /// PCM format: Integer 8-bit, native endianness
  PCMI8,

  /// PCM format: Integer 16-bit, native endianness
  PCMI16,

  /// PCM format: Float 32-bit, native endianness
  PCMF32,
}

/// Play state
enum PlayState {
  /// Playback is stopped
  ///
  /// After initialized, the player will be set initially as stopped
  stopped,

  /// Playback is ongoing
  playing,

  /// Playback is paused
  paused,
}

/// A player for playing the raw PCM audio data
class FlutterPcmPlayer {
  static const MethodChannel _channel = MethodChannel('flutter_pcm_player');

  bool _isInited = false;

  /// True if the player is already initialized by initialize()
  bool get isInited => _isInited;

  PlayState _playState = PlayState.stopped;

  /// The play state of the player
  PlayState get playState => _playState;

  /// True if the playback is ongoing
  ///
  /// Shortcut for ```player.playState == PlayState.playing```
  bool get isPlaying => _playState == PlayState.playing;

  /// True if the playback is paused
  ///
  /// Shortcut for ```player.playState == PlayState.paused```
  bool get isPaused => _playState == PlayState.paused;

  /// True if the playback is stopped
  ///
  /// Shortcut for ```player.playState == PlayState.stopped```
  bool get isStopped => _playState == PlayState.stopped;

  /// Initializes the player
  /// The [nChannels] should either be 1 or 2 to indicate the number of channels
  ///
  /// The [sampleRate] is the sample rate for output
  ///
  /// The [pcmType] determines the raw PCM format
  Future<void> initialize({
    int nChannels = 1,
    int sampleRate = 16000,
    PCMType pcmType = PCMType.PCMI16,
  }) async {
    release();

    await _channel.invokeMethod("initialize", {
      'nChannels': nChannels,
      'sampleRate': sampleRate,
      'pcmType': pcmType.index,
    });
    _playState = PlayState.stopped;
    _isInited = true;
  }

  /// Releases the player
  /// Before the releasing the playback will be stopped
  Future<void> release() async {
    if (!_isInited) return;

    await stop();
    await _channel.invokeMethod("release");
    _playState = PlayState.stopped;
    _isInited = false;
  }

  /// Starts the playback
  ///
  /// Throws an [Exception] if the player is not initialized
  ///
  /// Throws an [Exception] if the playback is not started
  Future<void> play() async {
    _ensureInited();

    var state = await await _channel.invokeMethod("play");
    _playState = PlayState.values[state];
    if (_playState != PlayState.playing) {
      throw Exception('Player is not playing');
    }
  }

  /// Stops the playback
  ///
  /// Throws an [Exception] if the player is not initialized
  ///
  /// Throws an [Exception] if the playback is not stopped
  ///
  /// Stops the playback will drop the queued buffers
  Future<void> stop() async {
    _ensureInited();

    var state = await await _channel.invokeMethod("stop");
    _playState = PlayState.values[state];
    if (_playState == PlayState.playing) {
      throw Exception('Player is not stopped');
    }
  }

  /// Pauses the playback
  ///
  /// Throws an [Exception] if the player is not initialized
  ///
  /// Throws an [Exception] if the playback is not paused
  ///
  /// Pauses the playback will not drop the queued buffers
  Future<void> pause() async {
    _ensureInited();
    var state = await await _channel.invokeMethod("pause");
    _playState = PlayState.values[state];
    if (_playState != PlayState.paused) {
      throw Exception('Player is not paused');
    }
  }

  /// Resumes the playback that being paused
  ///
  /// Throws an [Exception] if the player is not initialized
  ///
  /// Throws an [Exception] if the playback is not resumed
  Future<void> resume() async {
    _ensureInited();
    var state = await await _channel.invokeMethod("resume");
    _playState = PlayState.values[state];
    if (_playState != PlayState.playing) {
      throw Exception('Player is not resumed');
    }
  }

  /// Feeds the player with raw PCM [data] block
  ///
  /// Throws an [Exception] if the player is not initialized
  ///
  /// The format of [data] must comply with the [pcmType] used to initialize the player.
  /// And the size of [data] should not be too small to cause underrun
  Future<void> feed(Uint8List data) async {
    _ensureInited();

    var state = await await _channel.invokeMethod("feed", {
      'data': data,
    });
    _playState = PlayState.values[state];
  }

  /// Sets the [volume]
  ///
  /// Throws an [Exception] if the player is not initialized
  ///
  /// The [volume] should be in range of [0.0, 1.0]
  Future<void> setVolume(double volume) async {
    _ensureInited();
    var state = await await _channel.invokeMethod("setVolume", {
      'volume': volume,
    });
    _playState = PlayState.values[state];
  }

  // ---------------------------------------------------------------------------

  void _ensureInited() {
    if (!_isInited) {
      throw Exception('Player is not initialized');
    }
  }
}
