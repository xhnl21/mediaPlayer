import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
import 'package:media_player/presentation/widgets.dart';

class SearchGenresScreen extends StatelessWidget {
  const SearchGenresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final genres = ['Pop', 'Rock', 'Jazz', 'Hip Hop'];
    final horizontalPadding = context.w(0.05).clamp(14.0, 28.0);
    final verticalPadding = context.h(0.015).clamp(8.0, 18.0);
    final cardHeight = context.h(0.088).clamp(64.0, 84.0);
    final iconBoxSize = context.iconSize(44);
    final playBtnSize = context.iconSize(36);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            children: [
              // Search input
              CommonTextField(
                hintText: 'Search...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textLight,
                  size: context.iconSize(20),
                ),
                onChanged: (query) =>
                    context.read<LibraryCubit>().search(query),
              ),
              SizedBox(height: context.h(0.018).clamp(10.0, 20.0)),

              // Genres List
              Expanded(
                child: BlocBuilder<LibraryCubit, LibraryState>(
                  builder: (context, state) {
                    return ListView.separated(
                      itemCount: genres.length,
                      separatorBuilder: (_, index) =>
                          SizedBox(height: context.h(0.015).clamp(8.0, 16.0)),
                      itemBuilder: (context, index) {
                        final genre = genres[index];
                        final isSelected = state.selectedGenre == genre;

                        return InkWell(
                          onTap: () =>
                              context.read<LibraryCubit>().selectGenre(genre),
                          borderRadius: BorderRadius.circular(
                            context.w(0.04).clamp(12.0, 20.0),
                          ),
                          child: Container(
                            height: cardHeight,
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(0.04).clamp(12.0, 20.0),
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.cardSurfaceLight
                                  : AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(
                                context.w(0.04).clamp(12.0, 20.0),
                              ),
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
                                  width: iconBoxSize,
                                  height: iconBoxSize,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTealDark.withValues(
                                      alpha: 0.3,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      iconBoxSize * 0.27,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.music_note_rounded,
                                    color: AppColors.textLight,
                                    size: context.iconSize(28),
                                  ),
                                ),
                                SizedBox(
                                  width: context.w(0.04).clamp(10.0, 20.0),
                                ),
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
                                              fontSize: context.sp(17),
                                            ),
                                      ),
                                      SizedBox(
                                        height: context
                                            .h(0.003)
                                            .clamp(1.0, 4.0),
                                      ),
                                      Text(
                                        'Lorem ipsum dolor sit amet\nadipiscing elit',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: context.sp(10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Play Action Button
                                Container(
                                  width: playBtnSize,
                                  height: playBtnSize,
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
                                    icon: Icon(
                                      Icons.play_arrow_rounded,
                                      color: AppColors.textLight,
                                      size: context.iconSize(22),
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
