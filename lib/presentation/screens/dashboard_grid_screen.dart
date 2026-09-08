import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';

class DashboardGridScreen extends StatelessWidget {
  const DashboardGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const categories = [
      _CategoryItem(
        icon: Icons.music_note_rounded,
        label: 'Lorem',
        screen: AppScreen.playlistTracks,
      ),
      _CategoryItem(
        icon: Icons.search_rounded,
        label: 'Lorem',
        screen: AppScreen.searchGenres,
      ),
      _CategoryItem(
        icon: Icons.person_rounded,
        label: 'Lorem',
        screen: AppScreen.profile,
      ),
      _CategoryItem(
        icon: Icons.settings_rounded,
        label: 'Lorem',
        screen: AppScreen.soundSettings,
      ),
      _CategoryItem(
        icon: Icons.play_arrow_rounded,
        label: 'Lorem',
        screen: AppScreen.albumDetail,
      ),
      _CategoryItem(
        icon: Icons.equalizer_rounded,
        label: 'Lorem',
        screen: AppScreen.equalizer,
      ),
      _CategoryItem(
        icon: Icons.star_rounded,
        label: 'Lorem',
        screen: AppScreen.myPlaylist,
      ),
      _CategoryItem(
        icon: Icons.radio_rounded,
        label: 'Lorem',
        screen: AppScreen.radioFm,
      ),
    ];

    final horizontalPadding = context.w(0.05).clamp(14.0, 28.0);
    final verticalPadding = context.h(0.015).clamp(8.0, 18.0);
    final gridSpacing = context.w(0.04).clamp(12.0, 20.0);
    final crossCount = (context.isTablet || context.isLandscape) ? 4 : 2;
    final aspectRatio = context.isLandscape ? 1.35 : (context.isTablet ? 1.25 : 1.15);
    final cardRadius = context.w(0.04).clamp(12.0, 20.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: context.h(0.01).clamp(4.0, 12.0)),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: gridSpacing,
                    mainAxisSpacing: gridSpacing,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return InkWell(
                      onTap: () {
                        context.read<NavigationCubit>().navigateTo(item.screen);
                      },
                      borderRadius: BorderRadius.circular(cardRadius),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceLight,
                          borderRadius: BorderRadius.circular(cardRadius),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: context.iconSize(42),
                              color: AppColors.textLight,
                            ),
                            SizedBox(height: context.h(0.012).clamp(6.0, 12.0)),
                            Text(
                              item.label,
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.textLight,
                                fontSize: context.sp(13),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _CategoryItem {
  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.screen,
  });

  final IconData icon;
  final String label;
  final AppScreen screen;
}
