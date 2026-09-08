import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/widgets.dart';

class SearchGenresScreen extends StatelessWidget {
  const SearchGenresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final genres = ['Pop', 'Rock', 'Jazz', 'Hip Hop'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // Search input
              CommonTextField(
                hintText: 'Search...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textLight,
                  size: 20,
                ),
                onChanged: (query) =>
                    context.read<LibraryCubit>().search(query),
              ),
              const SizedBox(height: 16),

              // Genres List
              Expanded(
                child: BlocBuilder<LibraryCubit, LibraryState>(
                  builder: (context, state) {
                    return ListView.separated(
                      itemCount: genres.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final genre = genres[index];
                        final isSelected = state.selectedGenre == genre;

                        return InkWell(
                          onTap: () =>
                              context.read<LibraryCubit>().selectGenre(genre),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 72,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.cardSurfaceLight
                                  : AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Music note icon
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTealDark.withValues(
                                      alpha: 0.3,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.music_note_rounded,
                                    color: AppColors.textLight,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Genre title and subtitle
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        genre,
                                        style: AppTypography.titleLarge
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Lorem ipsum dolor sit amet\nadipiscing elit',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Play Action Button
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? AppColors.accentCoral
                                        : AppColors.textLight.withValues(
                                            alpha: 0.2,
                                          ),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: AppColors.textLight,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      final tracks =
                                          state.filteredTracks.isNotEmpty
                                          ? state.filteredTracks
                                          : state.allTracks;
                                      if (tracks.isNotEmpty) {
                                        context
                                            .read<AudioPlayerCubit>()
                                            .playTrack(tracks.first);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
