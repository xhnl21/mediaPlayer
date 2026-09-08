import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/main.dart';
import 'package:media_player/presentation/cubits.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  setUpAll(() async {
    FlutterError.onError = (details) {
      // ignore: avoid_print
      print('FLUTTER_ERROR_DETAILS: $details');
    };
    await initDependencies();
  });

  const resolutions = <String, Size>{
    'Small Phone (360x640)': Size(360, 640),
    'Medium Phone (390x844)': Size(390, 844),
    'Large Phone (414x896)': Size(414, 896),
    'Tablet Portrait (768x1024)': Size(768, 1024),
    'Landscape / Wide Screen (1280x800)': Size(1280, 800),
  };

  group('Multi-Resolution Overflow Verification Tests', () {
    for (final entry in resolutions.entries) {
      final name = entry.key;
      final size = entry.value;

      testWidgets('Renders all screens on $name without visual overflows', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(const MediaPlayerApp());
        await tester.pumpAndSettle();

        // 1. Welcome Screen
        expect(tester.takeException(), isNull);
        expect(find.text('MOBILE APP'), findsOneWidget);

        // 2. Auth Screen (Log In & Sign Up tabs)
        final navCubit = tester
            .element(find.byType(MaterialApp))
            .read<NavigationCubit>();

        navCubit.navigateTo(AppScreen.auth);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('LOG IN'), findsWidgets);

        // Tap SIGN UP tab
        await tester.tap(find.text('SIGN UP'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Confirm password'), findsOneWidget);

        // 3. Dashboard Screen (Authenticate guest for protected screens)
        await tester
            .element(find.byType(MaterialApp))
            .read<AuthCubit>()
            .continueAsGuest();
        await tester.pumpAndSettle();

        navCubit.navigateTo(AppScreen.dashboardGrid);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.music_note_rounded), findsWidgets);

        // 4. Equalizer Screen
        // 4. Equalizer Screen
        navCubit.navigateTo(AppScreen.equalizer);
        await tester.pumpAndSettle();
        final errEq = tester.takeException();
        if (errEq != null) {
          // ignore: avoid_print
          print('DEBUG OVERFLOW ON EQUALIZER: $errEq');
        }
        expect(errEq, isNull, reason: 'EqualizerScreen overflowed');

        // 5. Radio FM Screen
        navCubit.navigateTo(AppScreen.radioFm);
        await tester.pumpAndSettle();
        final errRadio = tester.takeException();
        if (errRadio is FlutterError) {
          final buffer = StringBuffer();
          for (final d in errRadio.diagnostics) {
            buffer.writeln('${d.name}: ${d.toDescription()}');
          }
          // ignore: avoid_print
          print('DIAGNOSTICS_DUMP:\n$buffer');
        }
        expect(errRadio, isNull, reason: 'RadioFmScreen overflowed');
        expect(find.text('Radio FM'), findsOneWidget);

        // 6. Voice Recorder Screen
        navCubit.navigateTo(AppScreen.voiceRecorder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.mic_rounded), findsWidgets);

        // 7. Sound Settings Screen
        navCubit.navigateTo(AppScreen.soundSettings);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('LOREM COLOR'), findsOneWidget);

        // 8. My Playlist Screen
        navCubit.navigateTo(AppScreen.myPlaylist);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('My Playlist'), findsOneWidget);

        // 9. Playlist Tracks Screen
        navCubit.navigateTo(AppScreen.playlistTracks);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 10. Search Genres Screen
        navCubit.navigateTo(AppScreen.searchGenres);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 11. Album Detail Screen
        navCubit.navigateTo(AppScreen.albumDetail);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('LOREM'), findsOneWidget);

        // 12. Profile Screen
        navCubit.navigateTo(AppScreen.profile);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Log out'), findsOneWidget);
      });
    }

    testWidgets(
      'MyPlaylistScreen renders long track titles without RenderFlex overflow on small device with high pixel density',
      (tester) async {
        // Simulates Redmi Note 8 screen density (2.8 DPR, 360x640 logical resolution)
        tester.view.physicalSize = const Size(1008, 1792);
        tester.view.devicePixelRatio = 2.8;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(const MediaPlayerApp());
        await tester.pumpAndSettle();

        // Authenticate as guest so protected routes are accessible
        await tester
            .element(find.byType(MaterialApp))
            .read<AuthCubit>()
            .continueAsGuest();
        await tester.pumpAndSettle();

        final navCubit = tester
            .element(find.byType(MaterialApp))
            .read<NavigationCubit>();
        final playerCubit = tester
            .element(find.byType(MaterialApp))
            .read<AudioPlayerCubit>();

        const longTitleTrack = Track(
          id: 'long_title_1',
          title: 'Alexandra Stan - Mr. Saxobeat (Official Video)',
          artist: 'Alexandra Stan • Ultra Music Extended Dance Version',
          album: 'Saxobeats Deluxe',
          duration: Duration(minutes: 3, seconds: 15),
          audioUrl: '/storage/emulated/0/Music/saxobeat.mp3',
        );
        playerCubit.emit(
          playerCubit.state.copyWith(
            tracks: [longTitleTrack, ...playerCubit.state.tracks],
          ),
        );

        navCubit.navigateTo(AppScreen.myPlaylist);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.text('Alexandra Stan - Mr. Saxobeat (Official Video)'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.shopping_cart_outlined), findsNothing);
      },
    );
  });
}
