enum AudioRepeatMode {
  off,
  once,
  all;

  AudioRepeatMode get next {
    switch (this) {
      case AudioRepeatMode.off:
        return AudioRepeatMode.once;
      case AudioRepeatMode.once:
        return AudioRepeatMode.all;
      case AudioRepeatMode.all:
        return AudioRepeatMode.off;
    }
  }

  String get label {
    switch (this) {
      case AudioRepeatMode.off:
        return 'Repeat Off';
      case AudioRepeatMode.once:
        return 'Repeat Once';
      case AudioRepeatMode.all:
        return 'Repeat All';
    }
  }
}

/// Alias to match DDD requirement
typedef RepeatMode = AudioRepeatMode;
