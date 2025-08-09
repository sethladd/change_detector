import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:args/args.dart';
import 'package:change_detector/src/api_checksum.dart';
import 'package:change_detector/src/api_differ.dart';
import 'package:path/path.dart' as p;

const String checksumCommand = 'checksum';
const String compareCommand = 'compare';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addCommand(checksumCommand,
        ArgParser()..addOption('path', abbr: 'p', help: 'Path to the library'))
    ..addCommand(
        compareCommand,
        ArgParser()
          ..addOption('path', abbr: 'p', help: 'Path to the library')
          ..addOption('checksum',
              abbr: 'c', help: 'Path to the checksum file'));

  try {
    final results = parser.parse(args);

    if (results.command == null) {
      print('Usage: dart run bin/change_detector.dart <command> [options]');
      print(parser.usage);
      exit(1);
    }

    if (results.command?.name == checksumCommand) {
      final path = results.command?['path'];
      if (path == null) {
        print('Missing --path option for checksum command.');
        exit(1);
      }

      final result = await resolveFile2(path: p.normalize(p.absolute(path)));
      if (result is! ResolvedUnitResult) {
        print('Failed to resolve file: $path');
        exit(1);
      }

      final generator = ApiGenerator();
      final api = generator.generateApi(result.unit);
      final json = JsonEncoder.withIndent('  ').convert(api?.toJson());
      print(json);
    } else if (results.command?.name == compareCommand) {
      final path = results.command?['path'];
      final checksumPath = results.command?['checksum'];
      if (path == null || checksumPath == null) {
        print('Missing --path or --checksum option for compare command.');
        exit(1);
      }

      final oldApiJson = await File(checksumPath).readAsString();
      final oldApi = Api.fromJson(jsonDecode(oldApiJson));

      final result = await resolveFile2(path: p.normalize(p.absolute(path)));
      if (result is! ResolvedUnitResult) {
        print('Failed to resolve file: $path');
        exit(1);
      }

      final generator = ApiGenerator();
      final newApi = generator.generateApi(result.unit);

      final differ = ApiDiffer();
      final diffResult = differ.compare(oldApi, newApi!);

      print('Comparison Result: ${diffResult.changeType}');
      if (diffResult.reasons.isNotEmpty) {
        print('Reasons:');
        for (final reason in diffResult.reasons) {
          print('  - $reason');
        }
      }
    }
  } on FormatException catch (e) {
    print(e.message);
    print(parser.usage);
    exit(1);
  }
}
