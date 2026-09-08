import 'package:media_player/domain/entities/voice_recording.dart';
import 'package:media_player/domain/repositories/voice_recorder_repository.dart';

class StartVoiceRecordingUseCase {
  const StartVoiceRecordingUseCase(this._repository);
  final VoiceRecorderRepository _repository;

  Future<void> execute() => _repository.startRecording();
}

class StopVoiceRecordingUseCase {
  const StopVoiceRecordingUseCase(this._repository);
  final VoiceRecorderRepository _repository;

  Future<VoiceRecording?> execute() => _repository.stopRecording();
}

class GetVoiceRecordingsUseCase {
  const GetVoiceRecordingsUseCase(this._repository);
  final VoiceRecorderRepository _repository;

  Future<List<VoiceRecording>> execute() => _repository.getRecordings();
}

class DeleteVoiceRecordingUseCase {
  const DeleteVoiceRecordingUseCase(this._repository);
  final VoiceRecorderRepository _repository;

  Future<void> execute(String id) => _repository.deleteRecording(id);
}
