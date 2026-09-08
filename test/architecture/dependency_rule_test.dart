import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Clean Architecture Dependency Rule Tests', () {
    test('Presentation and Domain must NEVER import Infrastructure', () {
      final libDir = Directory('lib');
      final forbiddenPattern = RegExp(
        r'''import\s+['"].*?(?:infrastructure/|infrastructure\.dart)['"]''',
      );

      final violations = <String>[];

      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final path = entity.path.replaceAll(r'\', '/');

          // Check presentation, domain, and application layers
          final isRestrictedLayer = path.contains('lib/presentation/') ||
              path.contains('lib/domain/') ||
              path.contains('lib/application/');

          if (isRestrictedLayer) {
            final content = entity.readAsStringSync();
            final matches = forbiddenPattern.allMatches(content);
            for (final match in matches) {
              violations.add('$path -> ${match.group(0)}');
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Clean Architecture violation detected: Presentation, Domain, and Application layers must not depend on Infrastructure.\n'
            'Violations found:\n${violations.join('\n')}',
      );
    });

    test('Infrastructure barrel is only imported by DI Composition Root', () {
      final libDir = Directory('lib');
      final infraImportPattern = RegExp(
        r'''import\s+['"].*?infrastructure\.dart['"]''',
      );

      const allowedFile = 'lib/core/di/injection_container.dart';
      final violations = <String>[];

      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final path = entity.path.replaceAll(r'\', '/');
          if (path != allowedFile && !path.contains('lib/infrastructure/')) {
            final content = entity.readAsStringSync();
            if (infraImportPattern.hasMatch(content)) {
              violations.add(path);
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Infrastructure barrel must only be consumed by Service Locator ($allowedFile). Violations in: $violations',
      );
    });
  });
}
