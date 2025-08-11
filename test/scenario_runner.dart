import 'dart:io';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:change_detector/src/api_checksum.dart';
import 'package:change_detector/src/api_differ.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Represents a single expected change with its type and description
class ChangeDetail {
  final ChangeType changeType;
  final String description;

  ChangeDetail(this.changeType, this.description);
}

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

      // Extract expected change types from comments in the after file
      final afterCode = afterFile.readAsStringSync();
      final expectedChangeType = extractExpectedChangeType(afterCode);
      final allExpectedChanges = extractAllExpectedChanges(afterCode);

      // Print all expected changes for debugging
      if (allExpectedChanges.isNotEmpty) {
        print('Expected changes in $categoryName/$scenarioName/$exampleName:');
        for (final change in allExpectedChanges) {
          print(
              '  - ${change.changeType.name.toUpperCase()}: ${change.description}');
        }
      } else {
        print(
            'No explicit changes found in $categoryName/$scenarioName/$exampleName');
      }

      // Run the change detector
      final diffResult =
          await runChangeDetectorWithDetails(beforeFile.path, afterFile.path);
      final actualChangeType = diffResult.changeType;
      final actualReasons = diffResult.reasons;

      // Verify that the expected change type (most severe) matches the actual change type
      expect(actualChangeType, expectedChangeType,
          reason:
              'Change detector reported ${actualChangeType.name} but expected ${expectedChangeType.name} '
              'for $categoryName/$scenarioName/$exampleName');

      // For MAJOR changes, verify that at least one major breaking change was detected
      if (expectedChangeType == ChangeType.major) {
        final hasMajorReason =
            actualReasons.any((reason) => reason.startsWith('MAJOR:'));
        expect(hasMajorReason, true,
            reason:
                'Expected at least one MAJOR change reason in $categoryName/$scenarioName/$exampleName');
      }

      // For MINOR changes, verify that at least one minor change was detected and no major changes
      if (expectedChangeType == ChangeType.minor) {
        final hasMinorReason =
            actualReasons.any((reason) => reason.startsWith('MINOR:'));
        expect(hasMinorReason, true,
            reason:
                'Expected at least one MINOR change reason in $categoryName/$scenarioName/$exampleName');
      }
    }
  }

  /// Extracts the expected change types from comments in the code
  /// Looks for patterns like "- MAJOR breaking change" or "- MINOR change"
  /// Returns the most severe change type found (major > minor > none)
  ChangeType extractExpectedChangeType(String code) {
    // Look for MAJOR or MINOR in comments
    final majorPattern =
        RegExp(r'[-\s]MAJOR\s+breaking\s+change', caseSensitive: false);
    final minorPattern = RegExp(r'[-\s]MINOR\s+change', caseSensitive: false);

    final hasMajorChanges = majorPattern.hasMatch(code);
    final hasMinorChanges = minorPattern.hasMatch(code);

    // Return the most severe change type found
    if (hasMajorChanges) {
      return ChangeType.major;
    } else if (hasMinorChanges) {
      return ChangeType.minor;
    } else {
      // Default to none if no pattern is found
      return ChangeType.none;
    }
  }

  /// Extracts all expected change details from comments in the code
  /// Returns a list of ChangeDetail objects that include change type and description
  List<ChangeDetail> extractAllExpectedChanges(String code) {
    final changes = <ChangeDetail>[];

    // Match patterns like "- MAJOR breaking change: description" or "- MINOR change: description"
    // Also handles patterns without colon separator
    final majorPattern = RegExp(
      r'([-\s]MAJOR\s+breaking\s+change(?:\s*:\s*|\s+)([^\n]*?)(?=\n|\Z))',
      caseSensitive: false,
    );

    final minorPattern = RegExp(
      r'([-\s]MINOR\s+change(?:\s*:\s*|\s+)([^\n]*?)(?=\n|\Z))',
      caseSensitive: false,
    );

    // Extract all major changes
    for (final match in majorPattern.allMatches(code)) {
      final description = match.group(2)?.trim() ?? 'Major breaking change';
      changes.add(ChangeDetail(ChangeType.major, description));
    }

    // Extract all minor changes
    for (final match in minorPattern.allMatches(code)) {
      final description = match.group(2)?.trim() ?? 'Minor change';
      changes.add(ChangeDetail(ChangeType.minor, description));
    }

    return changes;
  }

  /// Runs the change detector on before and after code
  /// Returns the detected change type
  Future<ChangeType> runChangeDetector(
      String beforePath, String afterPath) async {
    final diffResult =
        await runChangeDetectorWithDetails(beforePath, afterPath);
    return diffResult.changeType;
  }

  /// Runs the change detector on before and after code
  /// Returns the full DiffResult with change type and reasons
  Future<DiffResult> runChangeDetectorWithDetails(
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

    return diffResult;
  }
}
