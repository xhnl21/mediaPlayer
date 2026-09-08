import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/presentation/widgets/text.dart';

void main() {
  group('Texts Widget Tests', () {
    testWidgets('renders user example correctly with FittedBox', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Texts(
              'example',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fittedBox: true,
            ),
          ),
        ),
      );

      expect(find.text('example'), findsOneWidget);
      expect(find.byType(FittedBox), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('example'));
      expect(textWidget.style?.fontSize, 16);
      expect(textWidget.style?.fontWeight, FontWeight.bold);

      final fittedBoxWidget = tester.widget<FittedBox>(find.byType(FittedBox));
      expect(fittedBoxWidget.fit, BoxFit.scaleDown);
      expect(fittedBoxWidget.alignment, Alignment.centerLeft);
    });

    testWidgets(
      'renders plain text without FittedBox when fittedBox is false',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Texts('Simple text', fontSize: 14)),
          ),
        );

        expect(find.text('Simple text'), findsOneWidget);
        expect(find.byType(FittedBox), findsNothing);

        final textWidget = tester.widget<Text>(find.text('Simple text'));
        expect(textWidget.style?.fontSize, 14);
      },
    );

    testWidgets('transforms text to uppercase when uppercase is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Texts('lowercase title', uppercase: true)),
        ),
      );

      expect(find.text('LOWERCASE TITLE'), findsOneWidget);
    });

    testWidgets('capitalizes first letter when capitalize is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Texts('capitalize me', capitalize: true)),
        ),
      );

      expect(find.text('Capitalize me'), findsOneWidget);
    });

    testWidgets('supports style parameter and overrides specific properties', (
      tester,
    ) async {
      const baseStyle = TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: Colors.blue,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Texts(
              'Styled text',
              style: baseStyle,
              color: Colors.red,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Styled text'));
      expect(textWidget.style?.fontSize, 20); // Retained from baseStyle
      expect(textWidget.style?.color, Colors.red); // Overridden
      expect(textWidget.style?.fontWeight, FontWeight.w900); // Overridden
    });

    testWidgets(
      'derives alignment from textAlign when wrapped in FittedBox and alignment is null',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Texts(
                'Centered text',
                textAlign: TextAlign.center,
                fittedBox: true,
              ),
            ),
          ),
        );

        final fittedBoxWidget = tester.widget<FittedBox>(
          find.byType(FittedBox),
        );
        expect(fittedBoxWidget.alignment, Alignment.center);
      },
    );
  });
}
