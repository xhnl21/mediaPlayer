import 'dart:async';

import 'package:media_player/domain/entities/voice_recording.dart';
import 'package:media_player/domain/repositories/voice_recorder_repository.dart';

class VoiceRecorderRepositoryImpl implements VoiceRecorderRepository {
  VoiceRecorderRepositoryImpl() {
    _recordings = [
      VoiceRecording(
        id: 'rec_1',
        title: 'Ipsum v Memo',
        duration: const Duration(minutes: 1, seconds: 12),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  late final List<VoiceRecording> _recordings;
  bool _isRecording = false;
  Duration _currentDuration = Duration.zero;
  Timer? _recordingTimer;

  final _isRecordingController = StreamController<bool>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _amplitudeController = StreamController<double>.broadcast();

  @override
  Stream<bool> get isRecordingStream => _isRecordingController.stream;

  @override
  Stream<Duration> get recordingDurationStream => _durationController.stream;

  @override
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  @override
  Future<void> startRecording() async {
    _isRecording = true;
    _currentDuration = Duration.zero;
    _isRecordingController.add(true);
    _durationController.add(_currentDuration);

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      _currentDuration += const Duration(seconds: 1);
      _durationController.add(_currentDuration);
      // Simulate amplitude fluctuations (0.2 to 0.95)
      final amp = 0.3 + (DateTime.now().millisecond % 65) / 100.0;
      _amplitudeController.add(amp);
    });
  }

  @override
  Future<VoiceRecording?> stopRecording() async {
    _isRecording = false;
    _isRecordingController.add(false);
    _recordingTimer?.cancel();

    if (_currentDuration > Duration.zero) {
      final recording = VoiceRecording(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Recording ${_recordings.length + 1}',
        duration: _currentDuration,
        createdAt: DateTime.now(),
      );
      _recordings.insert(0, recording);
      _currentDuration = Duration.zero;
      _durationController.add(Duration.zero);
      return recording;
    }
    return null;
  }

  @override
  Future<void> pauseRecording() async {
    _isRecording = false;
    _isRecordingController.add(false);
    _recordingTimer?.cancel();
  }

  @override
  Future<List<VoiceRecording>> getRecordings() async =>
      List.unmodifiable(_recordings);

  @override
  Future<void> deleteRecording(String id) async {
    _recordings.removeWhere((r) => r.id == id);
  }

  void dispose() {
    _recordingTimer?.cancel();
    _isRecordingController.close();
    _durationController.close();
    _amplitudeController.close();
  }
}
