import 'package:media_player/domain/entities/playlist.dart';
import 'package:media_player/domain/entities/radio_station.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/domain/value_objects/audio_frequency.dart';

class MusicMockDataSource {
  static final List<Track> defaultTracks = [
    const Track(
      id: 't1',
      title: 'Dolor sit',
      artist: '4 Dolor sit',
      duration: Duration(minutes: 2, seconds: 40),
      genre: 'Pop',
      isFavorite: true,
      isSelected: true,
    ),
    const Track(
      id: 't2',
      title: 'Dolor sit',
      artist: '4 Dolor sit',
      duration: Duration(minutes: 3, seconds: 15),
      genre: 'Pop',
      isFavorite: false,
      isSelected: true,
    ),
    const Track(
      id: 't3',
      title: 'Dolor sit',
      artist: '4 Dolor sit',
      duration: Duration(minutes: 2, seconds: 55),
      genre: 'Rock',
      isFavorite: true,
      isSelected: false,
    ),
    const Track(
      id: 't4',
      title: 'Dolor sit',
      artist: '4 Dolor sit',
      duration: Duration(minutes: 4, seconds: 10),
      genre: 'Jazz',
      isFavorite: false,
      isSelected: true,
    ),
    const Track(
      id: 't5',
      title: 'Dolor sit',
      artist: '4 Dolor sit',
      duration: Duration(minutes: 3, seconds: 42),
      genre: 'Hip Hop',
      isFavorite: false,
      isSelected: false,
    ),
    const Track(
      id: 't6',
      title: 'Dolor sit',
      artist: '4 Dolor sit',
      duration: Duration(minutes: 2, seconds: 30),
      genre: 'Pop',
      isFavorite: true,
      isSelected: true,
    ),
  ];

  static final List<Playlist> defaultPlaylists = [
    Playlist(
      id: 'p1',
      title: 'My Playlist',
      dateSubtitle: 'March 1 at 20:00',
      songCount: 100,
      durationMinutes: 155,
      isFeatured: true,
      tracks: defaultTracks,
    ),
    Playlist(
      id: 'p2',
      title: 'Lorem ipsum',
      dateSubtitle: 'March 1 at 09:00',
      songCount: 150,
      durationMinutes: 755,
      rating: 4.5,
      tracks: defaultTracks,
    ),
  ];

  static final List<RadioStation> defaultStations = [
    const RadioStation(
      id: 'r1',
      name: 'Radio FM 102.5',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
      frequency: AudioFrequency(102.5),
    ),
    const RadioStation(
      id: 'r2',
      name: 'Radio Hits 101.7',
      description: 'The best pop and rock hits all day.',
      frequency: AudioFrequency(101.7),
    ),
    const RadioStation(
      id: 'r3',
      name: 'Smooth Jazz 101.9',
      description: 'Relaxing jazz and acoustic melodies.',
      frequency: AudioFrequency(101.9),
    ),
    const RadioStation(
      id: 'r4',
      name: 'Classic Rock 102.3',
      description: 'Classic rock legends uninterrupted.',
      frequency: AudioFrequency(102.3),
    ),
    const RadioStation(
      id: 'r5',
      name: 'Urban Beat 102.8',
      description: 'Hip hop, rap and modern urban rhythms.',
      frequency: AudioFrequency(102.8),
    ),
    const RadioStation(
      id: 'r6',
      name: 'Electronic Pulse 103.4',
      description: 'Electronic dance and club tracks.',
      frequency: AudioFrequency(103.4),
    ),
  ];
}
