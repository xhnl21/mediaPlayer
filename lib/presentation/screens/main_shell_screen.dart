import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/router/route_names.dart';
import 'package:media_player/presentation/screens.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
import 'package:media_player/presentation/widgets.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, navState) {
        String location = '';
        try {
          location = GoRouterState.of(context).matchedLocation;
        } catch (_) {}

        final isWelcomeOrAuth =
            location == RouteNames.welcome ||
            location == RouteNames.auth ||
            (child == null &&
                (navState.currentScreen == AppScreen.welcome ||
                    navState.currentScreen == AppScreen.auth));

        final showBottomNav = !isWelcomeOrAuth;

        final canGoBack =
            location == RouteNames.myPlaylist ||
            location == RouteNames.album ||
            location == RouteNames.radio ||
            location == RouteNames.recorder ||
            location == RouteNames.settings ||
            (child == null &&
                (navState.currentScreen == AppScreen.myPlaylist ||
                    navState.currentScreen == AppScreen.albumDetail ||
                    navState.currentScreen == AppScreen.radioFm ||
                    navState.currentScreen == AppScreen.voiceRecorder ||
                    navState.currentScreen == AppScreen.soundSettings ||
                    navState.currentScreen == AppScreen.auth));

        final bottomNavIndex = _calculateNavIndex(
          location,
          navState.bottomNavIndex,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: canGoBack
              ? AppBar(
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textLight,
                      size: context.iconSize(20),
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(RouteNames.dashboard);
                      }
                      context.read<NavigationCubit>().navigateTo(
                        AppScreen.dashboardGrid,
                      );
                    },
                  ),
                )
              : null,
          body: child ?? _buildCurrentScreen(navState.currentScreen),
          bottomNavigationBar: showBottomNav
              ? CustomBottomNavBar(
                  selectedIndex: bottomNavIndex,
                  onItemSelected: (index) {
                    _onBottomNavTapped(context, index);
                  },
                )
              : null,
        );
      },
    );
  }

  int _calculateNavIndex(String location, int fallbackIndex) {
    if (location.startsWith(RouteNames.dashboard)) return 0;
    if (location.startsWith(RouteNames.search)) return 1;
    if (location.startsWith(RouteNames.tracks) ||
        location.startsWith(RouteNames.myPlaylist) ||
        location.startsWith(RouteNames.album)) {
      return 2;
    }
    if (location.startsWith(RouteNames.equalizer) ||
        location.startsWith(RouteNames.radio) ||
        location.startsWith(RouteNames.recorder)) {
      return 3;
    }
    if (location.startsWith(RouteNames.profile) ||
        location.startsWith(RouteNames.settings)) {
      return 4;
    }
    return fallbackIndex;
  }

  void _onBottomNavTapped(BuildContext context, int index) {
    context.read<NavigationCubit>().changeBottomNavIndex(index);
    switch (index) {
      case 0:
        context.go(RouteNames.dashboard);
      case 1:
        context.go(RouteNames.search);
      case 2:
        context.go(RouteNames.tracks);
      case 3:
        context.go(RouteNames.equalizer);
      case 4:
        context.go(RouteNames.profile);
    }
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
