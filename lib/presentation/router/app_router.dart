import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/router/route_names.dart';
import 'package:media_player/presentation/screens.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
import 'package:media_player/presentation/widgets.dart';

/// Helper to convert a Stream into a Listenable for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Central application router using GoRouter
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static GoRouter? _cachedRouter;

  static GoRouter get router {
    if (_cachedRouter == null) {
      throw StateError(
        'AppRouter.router has not been initialized. Call AppRouter.createRouter(authCubit) first.',
      );
    }
    return _cachedRouter!;
  }

  static GoRouter createRouter(
    AuthCubit authCubit, {
    String initialLocation = RouteNames.welcome,
    Listenable? customRefreshListenable,
  }) {
    _cachedRouter = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialLocation,
      refreshListenable:
          customRefreshListenable ?? GoRouterRefreshStream(authCubit.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authCubit.state;
        final isAuthenticated = authState is Authenticated;
        final location = state.matchedLocation;
        final isPublicRoute =
            location == RouteNames.welcome || location == RouteNames.auth;

        // If not authenticated and trying to access private route -> redirect to welcome
        if (!isAuthenticated && !isPublicRoute) {
          return RouteNames.welcome;
        }

        // If authenticated and on welcome or auth page -> redirect to dashboard
        if (isAuthenticated && isPublicRoute) {
          return RouteNames.dashboard;
        }

        return null;
      },
      routes: [
        // Public Unauthenticated Routes
        GoRoute(
          path: RouteNames.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: RouteNames.auth,
          builder: (context, state) => const AuthScreen(),
        ),

        // Authenticated Shell Route with persistent Bottom Navigation and Mini Player
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) {
            return MainShellScreen(child: child);
          },
          routes: [
            GoRoute(
              path: RouteNames.dashboard,
              builder: (context, state) => const DashboardGridScreen(),
            ),
            GoRoute(
              path: RouteNames.search,
              builder: (context, state) => const SearchGenresScreen(),
            ),
            GoRoute(
              path: RouteNames.tracks,
              builder: (context, state) => const PlaylistTracksScreen(),
            ),
            GoRoute(
              path: RouteNames.myPlaylist,
              builder: (context, state) => const MyPlaylistScreen(),
            ),
            GoRoute(
              path: RouteNames.album,
              builder: (context, state) => const AlbumDetailScreen(),
            ),
            GoRoute(
              path: RouteNames.radio,
              builder: (context, state) => const RadioFmScreen(),
            ),
            GoRoute(
              path: RouteNames.equalizer,
              builder: (context, state) => const EqualizerScreen(),
            ),
            GoRoute(
              path: RouteNames.recorder,
              builder: (context, state) => const VoiceRecorderScreen(),
            ),
            GoRoute(
              path: RouteNames.settings,
              builder: (context, state) => const SoundSettingsScreen(),
            ),
            GoRoute(
              path: RouteNames.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => _NotFoundScreen(state: state),
    );

    return _cachedRouter!;
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.state});

  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.08).clamp(16.0, 32.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.accentCoral,
                  size: context.iconSize(64),
                ),
                SizedBox(height: context.h(0.02).clamp(10.0, 20.0)),
                Text(
                  '404 - Page Not Found',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.textLight,
                    fontSize: context.sp(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.h(0.01).clamp(6.0, 12.0)),
                Text(
                  'The requested route "${state.matchedLocation}" could not be found.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: context.sp(12),
                  ),
                ),
                SizedBox(height: context.h(0.03).clamp(16.0, 30.0)),
                CommonCoralButton(
                  text: 'GO HOME',
                  width: context.w(0.4).clamp(130.0, 200.0),
                  onPressed: () {
                    context.go(RouteNames.welcome);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
