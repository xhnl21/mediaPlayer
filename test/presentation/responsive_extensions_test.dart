import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';

void main() {
  group('ResponsiveContext Extension Tests', () {
    testWidgets('calculates correct width and height ratios', (tester) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: Builder(
              builder: (context) {
                testContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(testContext.screenWidth, 390.0);
      expect(testContext.screenHeight, 844.0);
      expect(testContext.w(0.5), 195.0);
      expect(testContext.w(1.0), 390.0);
      expect(testContext.h(0.25), 211.0);
      expect(testContext.padding(0.04), 15.6);
      expect(testContext.isPortrait, isTrue);
      expect(testContext.isLandscape, isFalse);
      expect(testContext.isTablet, isFalse);
      expect(testContext.isSmallPhone, isFalse);
    });

    testWidgets('identifies small phones accurately', (tester) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(360, 640)),
            child: Builder(
              builder: (context) {
                testContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(testContext.screenWidth, 360.0);
      expect(testContext.isSmallPhone, isTrue);
      expect(testContext.isTablet, isFalse);
      expect(testContext.sp(16), lessThan(16.0));
      expect(testContext.iconSize(24), lessThan(24.0));
    });

    testWidgets('identifies tablets and scales typography safely', (
      tester,
    ) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                testContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(testContext.isTablet, isTrue);
      expect(testContext.isSmallPhone, isFalse);
      // Ensure sp doesn't explode beyond upper bounds
      expect(testContext.sp(16), greaterThan(16.0));
      expect(testContext.sp(16), lessThanOrEqualTo(24.0));
    });

    testWidgets('identifies landscape orientation and scales according to height', (
      tester,
    ) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(1280, 800),
            ),
            child: Builder(
              builder: (context) {
                testContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(testContext.isLandscape, isTrue);
      expect(testContext.isPortrait, isFalse);
      expect(testContext.isTablet, isTrue);
      expect(testContext.w(0.5), 640.0);
      expect(testContext.h(0.5), 400.0);
    });
  });
}
