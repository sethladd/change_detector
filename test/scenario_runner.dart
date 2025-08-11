import 'dart:io';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:change_detector/src/api_checksum.dart';
import 'package:change_detector/src/api_differ.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Class responsible for running tests on a specific scenario
class ScenarioRunner {
  /// Tests a specific scenario by comparing before and after code
  /// and verifying that the change detector correctly identifies the change type
  Future<void> testScenario(String scenarioPath) async {
    final scenarioName = p.basename(scenarioPath);
    final categoryName = p.basename(p.dirname(scenarioPath));

    // Find example directories
    final exampleDirs = Directory(scenarioPath)
        .listSync()
        .whereType<Directory>()
        .where((dir) => p.basename(dir.path).startsWith('ex'))
        .toList();

    for (final exampleDir in exampleDirs) {
      final exampleName = p.basename(exampleDir.path);
      final beforeDir = Directory('${exampleDir.path}/before');
      final afterDir = Directory('${exampleDir.path}/after');

      if (!beforeDir.existsSync() || !afterDir.existsSync()) {
        fail('Missing before or after directory in $exampleDir');
      }

      final beforeFile = File('${beforeDir.path}/example.dart');
      final afterFile = File('${afterDir.path}/example.dart');

      if (!beforeFile.existsSync() || !afterFile.existsSync()) {
        fail(
            'Missing example.dart in before or after directory in $exampleDir');
      }

      // Extract expected change type from comments in the after file
      final afterCode = afterFile.readAsStringSync();
      final expectedChangeType = extractExpectedChangeType(afterCode);

      // Run the change detector
      final actualChangeType =
          await runChangeDetector(beforeFile.path, afterFile.path);

      // Verify results
      expect(actualChangeType, expectedChangeType,
          reason:
              'Change detector reported ${actualChangeType.name} but expected ${expectedChangeType.name} '
              'for $categoryName/$scenarioName/$exampleName');
    }
  }

  /// Extracts the expected change type from comments in the code
  /// Looks for patterns like "- MAJOR breaking change" or "- MINOR change"
  ChangeType extractExpectedChangeType(String code) {
    // Look for MAJOR or MINOR in comments
    final majorPattern =
        RegExp(r'[-\s]MAJOR\s+breaking\s+change', caseSensitive: false);
    final minorPattern = RegExp(r'[-\s]MINOR\s+change', caseSensitive: false);

    if (majorPattern.hasMatch(code)) {
      return ChangeType.major;
    } else if (minorPattern.hasMatch(code)) {
      return ChangeType.minor;
    } else {
      // Default to none if no pattern is found
      return ChangeType.none;
    }
  }

  /// Runs the change detector on before and after code
  /// Returns the detected change type
  Future<ChangeType> runChangeDetector(
      String beforePath, String afterPath) async {
    // Resolve the before file
    final beforeResult =
        await resolveFile2(path: p.normalize(p.absolute(beforePath)));
    if (beforeResult is! ResolvedUnitResult) {
      fail('Failed to resolve file: $beforePath');
    }

    // Resolve the after file
    final afterResult =
        await resolveFile2(path: p.normalize(p.absolute(afterPath)));
    if (afterResult is! ResolvedUnitResult) {
      fail('Failed to resolve file: $afterPath');
    }

    // Generate API checksums
    final generator = ApiGenerator();
    final oldApi = generator.generateApi(beforeResult.unit);
    final newApi = generator.generateApi(afterResult.unit);

    if (oldApi == null || newApi == null) {
      fail('Failed to generate API for $beforePath or $afterPath');
    }

    // Compare APIs
    final differ = ApiDiffer();
    final diffResult = differ.compare(oldApi, newApi);

    // Print detailed reasons for debugging
    print('Change type detected: ${diffResult.changeType}');
    if (diffResult.reasons.isNotEmpty) {
      print('Reasons:');
      for (final reason in diffResult.reasons) {
        print('  - $reason');
      }
    }

    return diffResult.changeType;
  }
}
