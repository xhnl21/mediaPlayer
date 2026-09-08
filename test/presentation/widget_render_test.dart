import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/main.dart';
import 'package:media_player/presentation/screens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  setUpAll(() async {
    await initDependencies();
  });

  group('Widget Presentation & Navigation Smoke Tests', () {
    testWidgets(
      'MediaPlayerApp renders WelcomeScreen and navigates to AuthScreen',
      (tester) async {
        await tester.pumpWidget(const MediaPlayerApp());
        await tester.pump();

        // Check Welcome Screen elements
        expect(find.byType(WelcomeScreen), findsOneWidget);
        expect(find.text('MOBILE APP'), findsOneWidget);
        expect(find.text('GET STARTED'), findsOneWidget);

        // Tap 'GET STARTED' button
        await tester.tap(find.text('GET STARTED'));
        await tester.pumpAndSettle();

        // Check Auth Screen rendered
        expect(find.text('LOG IN'), findsWidgets);
        expect(find.text('SIGN UP'), findsOneWidget);
        expect(find.text('Lorem ipsum dolor'), findsOneWidget);
      },
    );

    testWidgets('MediaPlayerApp can navigate to dashboard directly', (
      tester,
    ) async {
      await tester.pumpWidget(const MediaPlayerApp());
      await tester.pump();

      // Tap link at bottom of Welcome screen
      await tester.tap(find.text('Lorem ipsum dolor sit amet'));
      await tester.pumpAndSettle();

      // Grid with category tiles is visible
      expect(find.byIcon(Icons.music_note_rounded), findsWidgets);
      expect(find.byIcon(Icons.search_rounded), findsWidgets);
    });
  });
}
