import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return InkWell(
                      onTap: () {
                        context.read<NavigationCubit>().navigateTo(item.screen);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceLight,
                          borderRadius: BorderRadius.circular(16),
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
                              size: 42,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.label,
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.textLight,
                                fontSize: 13,
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
