import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/presentation/router/app_router.dart';
import 'package:media_player/presentation/router/route_names.dart';

enum AppScreen {
  welcome, // 01
  auth, // 02
  profile, // 03
  dashboardGrid, // 04
  playlistTracks, // 05
  myPlaylist, // 06
  searchGenres, // 07
  albumDetail, // 08
  radioFm, // 09
  equalizer, // 10
  voiceRecorder, // 11
  soundSettings, // 12
}

extension AppScreenExtension on AppScreen {
  String get routePath {
    switch (this) {
      case AppScreen.welcome:
        return RouteNames.welcome;
      case AppScreen.auth:
        return RouteNames.auth;
      case AppScreen.dashboardGrid:
        return RouteNames.dashboard;
      case AppScreen.searchGenres:
        return RouteNames.search;
      case AppScreen.playlistTracks:
        return RouteNames.tracks;
      case AppScreen.myPlaylist:
        return RouteNames.myPlaylist;
      case AppScreen.albumDetail:
        return RouteNames.album;
      case AppScreen.radioFm:
        return RouteNames.radio;
      case AppScreen.equalizer:
        return RouteNames.equalizer;
      case AppScreen.voiceRecorder:
        return RouteNames.recorder;
      case AppScreen.soundSettings:
        return RouteNames.settings;
      case AppScreen.profile:
        return RouteNames.profile;
    }
  }
}

class NavigationState extends Equatable {
  const NavigationState({
    this.currentScreen = AppScreen.welcome,
    this.bottomNavIndex = 0,
    this.extraData,
  });

  final AppScreen currentScreen;
  final int bottomNavIndex;
  final Object? extraData;

  NavigationState copyWith({
    AppScreen? currentScreen,
    int? bottomNavIndex,
    Object? extraData,
  }) {
    return NavigationState(
      currentScreen: currentScreen ?? this.currentScreen,
      bottomNavIndex: bottomNavIndex ?? this.bottomNavIndex,
      extraData: extraData ?? this.extraData,
    );
  }

  @override
  List<Object?> get props => [currentScreen, bottomNavIndex, extraData];
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void navigateTo(AppScreen screen, {Object? extra}) {
    int navIndex = state.bottomNavIndex;
    switch (screen) {
      case AppScreen.dashboardGrid:
        navIndex = 0;
      case AppScreen.searchGenres:
        navIndex = 1;
      case AppScreen.playlistTracks:
      case AppScreen.myPlaylist:
      case AppScreen.albumDetail:
        navIndex = 2;
      case AppScreen.equalizer:
      case AppScreen.radioFm:
      case AppScreen.voiceRecorder:
        navIndex = 3;
      case AppScreen.profile:
      case AppScreen.soundSettings:
        navIndex = 4;
      default:
        break;
    }
    emit(
      state.copyWith(
        currentScreen: screen,
        bottomNavIndex: navIndex,
        extraData: extra,
      ),
    );

    try {
      AppRouter.router.go(screen.routePath);
    } catch (_) {
      // Router may not be initialized in isolated unit tests
    }
  }

  void changeBottomNavIndex(int index) {
    AppScreen targetScreen;
    switch (index) {
      case 0:
        targetScreen = AppScreen.dashboardGrid;
      case 1:
        targetScreen = AppScreen.searchGenres;
      case 2:
        targetScreen = AppScreen.playlistTracks;
      case 3:
        targetScreen = AppScreen.equalizer;
      case 4:
        targetScreen = AppScreen.profile;
      default:
        targetScreen = AppScreen.dashboardGrid;
    }
    emit(state.copyWith(currentScreen: targetScreen, bottomNavIndex: index));

    try {
      AppRouter.router.go(targetScreen.routePath);
    } catch (_) {}
  }
}
