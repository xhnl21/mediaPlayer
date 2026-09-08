import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/application/favorites.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/domain/favorites.dart';
import 'package:media_player/presentation/cubits/favorites/favorites_state.dart';
import 'package:uuid/uuid.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({
    required this.getFavoritesUseCase,
    required this.toggleFavoriteTrackUseCase,
    required this.removeFavoriteTrackUseCase,
    this.favoritesRepository,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid(),
       super(const FavoritesState()) {
    _initSubscription();
    loadFavorites();
  }

  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteTrackUseCase toggleFavoriteTrackUseCase;
  final RemoveFavoriteTrackUseCase removeFavoriteTrackUseCase;
  final FavoritesRepository? favoritesRepository;
  final Uuid _uuid;
  StreamSubscription<List<FavoriteTrack>>? _sub;

  void _initSubscription() {
    if (favoritesRepository != null) {
      _sub = favoritesRepository!.favoritesStream.listen((favs) {
        emit(
          state.copyWith(
            favorites: favs,
            favoriteTrackIds: favs.map((f) => f.trackId).toSet(),
          ),
        );
      });
    }
  }

  Future<void> loadFavorites() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final favs = await getFavoritesUseCase.execute();
      emit(
        state.copyWith(
          favorites: favs,
          favoriteTrackIds: favs.map((f) => f.trackId).toSet(),
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load favorites: $e',
        ),
      );
    }
  }

  Future<void> toggleFavorite(Track track) async {
    try {
      final favorite = FavoriteTrack(
        id: _uuid.v4(),
        trackId: track.id,
        title: track.title,
        artist: track.artist,
        album: track.album,
        duration: track.duration,
        audioUrl: track.audioUrl,
        addedAt: DateTime.now(),
      );
      await toggleFavoriteTrackUseCase.execute(favorite);
      await loadFavorites();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update favorite: $e'));
    }
  }

  Future<void> removeFavorite(String trackId) async {
    try {
      await removeFavoriteTrackUseCase.execute(trackId);
      await loadFavorites();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to remove favorite: $e'));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
