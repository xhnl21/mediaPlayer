import 'package:equatable/equatable.dart';
import 'package:media_player/domain/favorites.dart';

class FavoritesState extends Equatable {
  const FavoritesState({
    this.favorites = const [],
    this.favoriteTrackIds = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  final List<FavoriteTrack> favorites;
  final Set<String> favoriteTrackIds;
  final bool isLoading;
  final String? errorMessage;

  bool isFavorite(String trackId) => favoriteTrackIds.contains(trackId);

  FavoritesState copyWith({
    List<FavoriteTrack>? favorites,
    Set<String>? favoriteTrackIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      favoriteTrackIds: favoriteTrackIds ?? this.favoriteTrackIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    favorites,
    favoriteTrackIds,
    isLoading,
    errorMessage,
  ];
}
