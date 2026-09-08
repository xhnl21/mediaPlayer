import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/screens.dart';
import 'package:media_player/presentation/widgets.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, navState) {
        final showBottomNav =
            navState.currentScreen != AppScreen.welcome &&
            navState.currentScreen != AppScreen.auth;

        final canGoBack =
            navState.currentScreen == AppScreen.myPlaylist ||
            navState.currentScreen == AppScreen.albumDetail ||
            navState.currentScreen == AppScreen.radioFm ||
            navState.currentScreen == AppScreen.voiceRecorder ||
            navState.currentScreen == AppScreen.soundSettings ||
            navState.currentScreen == AppScreen.auth;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: canGoBack
              ? AppBar(
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textLight,
                      size: 20,
                    ),
                    onPressed: () {
                      if (navState.currentScreen == AppScreen.auth) {
                        context.read<NavigationCubit>().navigateTo(
                          AppScreen.welcome,
                        );
                      } else {
                        context.read<NavigationCubit>().navigateTo(
                          AppScreen.dashboardGrid,
                        );
                      }
                    },
                  ),
                )
              : null,
          body: _buildCurrentScreen(navState.currentScreen),
          bottomNavigationBar: showBottomNav
              ? CustomBottomNavBar(
                  selectedIndex: navState.bottomNavIndex,
                  onItemSelected: (index) {
                    context.read<NavigationCubit>().changeBottomNavIndex(index);
                  },
                )
              : null,
        );
      },
    );
  }

  Widget _buildCurrentScreen(AppScreen screen) {
    switch (screen) {
      case AppScreen.welcome:
        return const WelcomeScreen();
      case AppScreen.auth:
        return const AuthScreen();
      case AppScreen.profile:
        return const ProfileScreen();
      case AppScreen.dashboardGrid:
        return const DashboardGridScreen();
      case AppScreen.playlistTracks:
        return const PlaylistTracksScreen();
      case AppScreen.myPlaylist:
        return const MyPlaylistScreen();
      case AppScreen.searchGenres:
        return const SearchGenresScreen();
      case AppScreen.albumDetail:
        return const AlbumDetailScreen();
      case AppScreen.radioFm:
        return const RadioFmScreen();
      case AppScreen.equalizer:
        return const EqualizerScreen();
      case AppScreen.voiceRecorder:
        return const VoiceRecorderScreen();
      case AppScreen.soundSettings:
        return const SoundSettingsScreen();
    }
  }
}
