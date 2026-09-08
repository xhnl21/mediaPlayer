import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class LocalAudioDataSource {
  Future<bool> checkPermissions();
  Future<bool> requestPermissions();
  Future<List<Track>> queryTracks();
  Future<bool> deletePhysicalTrack({
    required String audioUrl,
    required String trackId,
  });
  Future<bool> deletePhysicalTracks(List<Track> tracks);
}

class LocalAudioDataSourceImpl implements LocalAudioDataSource {
  LocalAudioDataSourceImpl({OnAudioQuery? audioQuery})
    : _audioQuery = audioQuery ?? OnAudioQuery();

  final OnAudioQuery _audioQuery;
  static const _channel = MethodChannel(
    'com.antigravity.mediaplayer/device_audio',
  );

  @override
  Future<bool> checkPermissions() async {
    try {
      if (kIsWeb) return true;

      // First check OnAudioQuery built-in permission status
      final queryStatus = await _audioQuery.permissionsStatus();
      if (queryStatus) return true;

      if (Platform.isAndroid) {
        // On Android 13+ (API 33+), check Permission.audio
        final audioStatus = await Permission.audio.status;
        if (audioStatus.isGranted || audioStatus.isLimited) return true;

        // Check manageExternalStorage on Android 11+
        final manageStatus = await Permission.manageExternalStorage.status;
        if (manageStatus.isGranted) return true;

        // Fallback check for storage permission on Android <= 12
        final storageStatus = await Permission.storage.status;
        return storageStatus.isGranted || storageStatus.isLimited;
      } else if (Platform.isIOS) {
        final status = await Permission.mediaLibrary.status;
        return status.isGranted || status.isLimited;
      }
      return true;
    } catch (e) {
      debugPrint('LocalAudioDataSource.checkPermissions exception: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      if (kIsWeb) return true;

      // OnAudioQuery checkAndRequest handles version-specific permissions internally
      final grantedFromQuery = await _audioQuery.checkAndRequest(
        retryRequest: true,
      );
      if (grantedFromQuery) return true;

      if (Platform.isAndroid) {
        // Request Permission.audio for Android 13+
        final audioStatus = await Permission.audio.request();
        if (audioStatus.isGranted || audioStatus.isLimited) return true;

        // Fallback request storage for Android <= 12
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted || storageStatus.isLimited) return true;

        // Request manageExternalStorage for Android 11+
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus.isGranted;
      } else if (Platform.isIOS) {
        final status = await Permission.mediaLibrary.request();
        return status.isGranted || status.isLimited;
      }
      return false;
    } catch (e) {
      debugPrint('LocalAudioDataSource.requestPermissions exception: $e');
      return false;
    }
  }

  @override
  Future<List<Track>> queryTracks() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        debugPrint('LocalAudioDataSource: Permissions not granted.');
        return [];
      }

      final songModels = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      final tracks = <Track>[];
      for (final song in songModels) {
        // Filter out very short sound clips (< 3 seconds) or non-music if flag is set
        final durationMs = song.duration ?? 0;
        if (song.isMusic == false && durationMs < 3000) {
          continue;
        }

        // Prioritize actual physical file path (song.data) over content URI so dart:io and media scanner can resolve it
        final audioUri = (song.data.trim().isNotEmpty)
            ? song.data.trim()
            : ((song.uri != null && song.uri!.trim().isNotEmpty)
                  ? song.uri!
                  : '');

        tracks.add(
          Track(
            id: song.id.toString(),
            title: song.title.trim().isNotEmpty
                ? song.title.trim()
                : 'Unknown Title',
            artist:
                (song.artist != null &&
                    song.artist!.trim().isNotEmpty &&
                    song.artist != '<unknown>')
                ? song.artist!.trim()
                : 'Unknown Artist',
            album:
                (song.album != null &&
                    song.album!.trim().isNotEmpty &&
                    song.album != '<unknown>')
                ? song.album!.trim()
                : '',
            duration: Duration(milliseconds: durationMs),
            audioUrl: audioUri,
            genre: (song.genre != null && song.genre!.trim().isNotEmpty)
                ? song.genre!
                : 'Local Audio',
            isFavorite: false,
            isSelected: false,
          ),
        );
      }

      return tracks;
    } catch (e) {
      debugPrint('LocalAudioDataSource.queryTracks exception: $e');
      return [];
    }
  }

  @override
  Future<bool> deletePhysicalTrack({
    required String audioUrl,
    required String trackId,
  }) async {
    return deletePhysicalTracks([
      Track(
        id: trackId,
        title: '',
        artist: '',
        duration: Duration.zero,
        audioUrl: audioUrl,
      ),
    ]);
  }

  @override
  Future<bool> deletePhysicalTracks(List<Track> tracks) async {
    if (tracks.isEmpty) return true;

    final validTracks = tracks.where((t) {
      final url = t.audioUrl.trim();
      return url.isNotEmpty &&
          !url.startsWith('http://') &&
          !url.startsWith('https://') &&
          !url.startsWith('mock://');
    }).toList();

    if (validTracks.isEmpty) return false;

    bool deleted = false;

    // 1. Invoke native Android channel in a single batch request (MediaStore prompts only ONCE)
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final items = validTracks
            .map((t) => {'path': t.audioUrl, 'id': t.id})
            .toList();
        final result = await _channel.invokeMethod<bool>('deleteAudios', {
          'items': items,
        });
        if (result == true) {
          deleted = true;
        }
      } catch (e) {
        debugPrint(
          'LocalAudioDataSource.deletePhysicalTracks native channel exception: $e',
        );
      }
    }

    // 2. Direct filesystem deletion fallback for all tracks (works on iOS, desktop, unit tests)
    for (final track in validTracks) {
      try {
        final file = File(track.audioUrl);
        if (await file.exists()) {
          await file.delete();
          deleted = true;
        }
      } catch (e) {
        debugPrint(
          'LocalAudioDataSource.deletePhysicalTracks direct File exception for ${track.audioUrl}: $e',
        );
      }
    }

    // 3. Rescan media for all paths so on_audio_query and Android system update cache
    if (!kIsWeb && Platform.isAndroid) {
      for (final track in validTracks) {
        if (!track.audioUrl.startsWith('content://')) {
          try {
            await _audioQuery.scanMedia(track.audioUrl);
          } catch (e) {
            debugPrint('LocalAudioDataSource scanMedia exception: $e');
          }
        }
      }
    }

    return deleted;
  }
}
