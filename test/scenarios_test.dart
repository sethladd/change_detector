import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'scenario_runner.dart';

void main() {
  group('Scenario Tests', () {
    final scenarioRunner = ScenarioRunner();

    // Test for all scenarios
    final scenariosDir = Directory('scenarios');
    if (!scenariosDir.existsSync()) {
      fail('Scenarios directory not found');
    }

    // Get major and minor change directories
    final categoryDirs = scenariosDir
        .listSync()
        .whereType<Directory>()
        .where((dir) => ['major', 'minor'].contains(p.basename(dir.path)))
        .toList();

    for (final categoryDir in categoryDirs) {
      final categoryName = p.basename(categoryDir.path);

      // Get all scenario directories within this category
      final scenarioDirs =
          categoryDir.listSync().whereType<Directory>().toList();

      for (final scenarioDir in scenarioDirs) {
        final scenarioName = p.basename(scenarioDir.path);

        test('$categoryName Change - $scenarioName', () async {
          await scenarioRunner.testScenario(scenarioDir.path);
        });
      }
    }
  });
}
