import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/application/player.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/domain/player.dart';

class LibraryState extends Equatable {
  const LibraryState({
    this.playlists = const [],
    this.allTracks = const [],
    this.filteredTracks = const [],
    this.searchQuery = '',
    this.selectedGenre = 'All',
    this.selectedTab = 'Lorem ipsum',
    this.isLoading = false,
  });

  final List<Playlist> playlists;
  final List<Track> allTracks;
  final List<Track> filteredTracks;
  final String searchQuery;
  final String selectedGenre;
  final String selectedTab; // For Screen 6: 'Lorem ipsum' | 'Lorem dolor'
  final bool isLoading;

  LibraryState copyWith({
    List<Playlist>? playlists,
    List<Track>? allTracks,
    List<Track>? filteredTracks,
    String? searchQuery,
    String? selectedGenre,
    String? selectedTab,
    bool? isLoading,
  }) {
    return LibraryState(
      playlists: playlists ?? this.playlists,
      allTracks: allTracks ?? this.allTracks,
      filteredTracks: filteredTracks ?? this.filteredTracks,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    playlists,
    allTracks,
    filteredTracks,
    searchQuery,
    selectedGenre,
    selectedTab,
    isLoading,
  ];
}

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit({
    required this.getPlaylistsUseCase,
    required this.getTracksUseCase,
    required this.searchTracksUseCase,
  }) : super(const LibraryState()) {
    loadLibrary();
  }

  final GetPlaylistsUseCase getPlaylistsUseCase;
  final GetTracksUseCase getTracksUseCase;
  final SearchTracksUseCase searchTracksUseCase;

  Future<void> loadLibrary() async {
    emit(state.copyWith(isLoading: true));
    final playlists = await getPlaylistsUseCase.execute();
    final tracks = await getTracksUseCase.execute();
    emit(
      state.copyWith(
        playlists: playlists,
        allTracks: tracks,
        filteredTracks: tracks,
        isLoading: false,
      ),
    );
  }

  Future<void> search(String query) async {
    final sanitized = InputSanitizer.sanitizeQuery(query);
    emit(state.copyWith(searchQuery: sanitized, isLoading: true));
    if (sanitized.isEmpty) {
      _filterByGenre(state.selectedGenre);
      return;
    }
    final results = await searchTracksUseCase.execute(sanitized);
    emit(state.copyWith(filteredTracks: results, isLoading: false));
  }

  void selectGenre(String genre) {
    emit(state.copyWith(selectedGenre: genre));
    _filterByGenre(genre);
  }

  void _filterByGenre(String genre) {
    if (genre == 'All') {
      emit(state.copyWith(filteredTracks: state.allTracks, isLoading: false));
    } else {
      final filtered = state.allTracks
          .where((t) => t.genre.toLowerCase() == genre.toLowerCase())
          .toList();
      emit(state.copyWith(filteredTracks: filtered, isLoading: false));
    }
  }

  void selectTab(String tab) {
    emit(state.copyWith(selectedTab: tab));
  }
}
