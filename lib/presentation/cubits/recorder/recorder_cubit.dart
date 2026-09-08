import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/application/recorder.dart';
import 'package:media_player/domain/recorder.dart';

class RecorderState extends Equatable {
  const RecorderState({
    this.isRecording = false,
    this.duration = Duration.zero,
    this.amplitude = 0.4,
    this.recordings = const [],
    this.selectedMemoTitle = 'Ipsum v',
  });

  final bool isRecording;
  final Duration duration;
  final double amplitude; // 0.0 to 1.0 for concentric mic pulse
  final List<VoiceRecording> recordings;
  final String selectedMemoTitle;

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  RecorderState copyWith({
    bool? isRecording,
    Duration? duration,
    double? amplitude,
    List<VoiceRecording>? recordings,
    String? selectedMemoTitle,
  }) {
    return RecorderState(
      isRecording: isRecording ?? this.isRecording,
      duration: duration ?? this.duration,
      amplitude: amplitude ?? this.amplitude,
      recordings: recordings ?? this.recordings,
      selectedMemoTitle: selectedMemoTitle ?? this.selectedMemoTitle,
    );
  }

  @override
  List<Object?> get props => [
    isRecording,
    duration,
    amplitude,
    recordings,
    selectedMemoTitle,
  ];
}

class RecorderCubit extends Cubit<RecorderState> {
  RecorderCubit({
    required this.recorderRepository,
    required this.startVoiceRecordingUseCase,
    required this.stopVoiceRecordingUseCase,
    required this.getVoiceRecordingsUseCase,
    required this.deleteVoiceRecordingUseCase,
  }) : super(const RecorderState()) {
    _initSubscriptions();
  }

  final VoiceRecorderRepository recorderRepository;
  final StartVoiceRecordingUseCase startVoiceRecordingUseCase;
  final StopVoiceRecordingUseCase stopVoiceRecordingUseCase;
  final GetVoiceRecordingsUseCase getVoiceRecordingsUseCase;
  final DeleteVoiceRecordingUseCase deleteVoiceRecordingUseCase;

  StreamSubscription<bool>? _recordingSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<double>? _amplitudeSub;

  void _initSubscriptions() {
    _recordingSub = recorderRepository.isRecordingStream.listen((recording) {
      emit(state.copyWith(isRecording: recording));
    });
    _durationSub = recorderRepository.recordingDurationStream.listen((dur) {
      emit(state.copyWith(duration: dur));
    });
    _amplitudeSub = recorderRepository.amplitudeStream.listen((amp) {
      emit(state.copyWith(amplitude: amp));
    });

    loadRecordings();
  }

  Future<void> loadRecordings() async {
    final recs = await getVoiceRecordingsUseCase.execute();
    emit(state.copyWith(recordings: recs));
  }

  Future<void> toggleRecording() async {
    if (state.isRecording) {
      await stopVoiceRecordingUseCase.execute();
      await loadRecordings();
    } else {
      await startVoiceRecordingUseCase.execute();
    }
  }

  Future<void> deleteRecording(String id) async {
    await deleteVoiceRecordingUseCase.execute(id);
    await loadRecordings();
  }

  void selectMemoTitle(String title) {
    emit(state.copyWith(selectedMemoTitle: title));
  }

  @override
  Future<void> close() {
    _recordingSub?.cancel();
    _durationSub?.cancel();
    _amplitudeSub?.cancel();
    return super.close();
  }
}
