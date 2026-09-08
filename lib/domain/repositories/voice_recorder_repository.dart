import 'package:media_player/domain/entities/voice_recording.dart';

abstract class VoiceRecorderRepository {
  Stream<bool> get isRecordingStream;
  Stream<Duration> get recordingDurationStream;
  Stream<double> get amplitudeStream;

  Future<void> startRecording();
  Future<VoiceRecording?> stopRecording();
  Future<void> pauseRecording();
  Future<List<VoiceRecording>> getRecordings();
  Future<void> deleteRecording(String id);
}
