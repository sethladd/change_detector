import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:change_detector/src/api_checksum.dart';
import 'package:change_detector/src/api_differ.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('change_detector_test');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('Snippet-based tests', () {
    test('reports no changes for identical code', () async {
      final code = '''
        class MyClass {
          void myMethod() {}
        }
      ''';
      final result = await diff(code, code);
      expect(result.changeType, equals(ChangeType.none));
    });

    group('Parameter changes', () {
      test('adding a required parameter is a MAJOR change', () async {
        final before = 'class C { void m() {} }';
        final after = 'class C { void m(int a) {} }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Added required parameter a to method m'));
      });

      test('adding an optional parameter is a MINOR change', () async {
        final before = 'class C { void m() {} }';
        final after = 'class C { void m([int? a]) {} }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons,
            contains('MINOR: Added optional parameter a to method m'));
      });

      test('removing a parameter is a MAJOR change', () async {
        final before = 'class C { void m(int a) {} }';
        final after = 'class C { void m() {} }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Removed parameter a from method m'));
      });

      test('changing a parameter type is a MAJOR change', () async {
        final before = 'class C { void m(int a) {} }';
        final after = 'class C { void m(String a) {} }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Parameter a in method m changed type from int to String'));
      });

      test('changing an optional parameter to required is a MAJOR change',
          () async {
        final before = 'class C { void m([int? a]) {} }';
        final after = 'class C { void m(int a) {} }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Parameter a in method m changed from optional to required'));
      });

      test('changing a required parameter to optional is a MINOR change',
          () async {
        final before = 'class C { void m(int a) {} }';
        final after = 'class C { void m([int? a]) {} }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.minor));
        expect(
            result.reasons,
            contains(
                'MINOR: Parameter a in method m changed from required to optional'));
      });

      test('renaming a named parameter is a MAJOR change', () async {
        final before = 'class C { void m({int? a}) {} }';
        final after = 'class C { void m({int? b}) {} }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Named parameter a in method m was renamed to b'));
      });
    });

    group('Top-level declaration changes', () {
      test('adding a function is a MINOR change', () async {
        final before = '';
        final after = 'void f() {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons, contains('MINOR: Added function f'));
      });

      test('removing a function is a MAJOR change', () async {
        final before = 'void f() {}';
        final after = '';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Removed function f'));
      });

      test('adding a variable is a MINOR change', () async {
        final before = '';
        final after = 'int a = 1;';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons, contains('MINOR: Added variable a'));
      });

      test('removing a variable is a MAJOR change', () async {
        final before = 'int a = 1;';
        final after = '';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Removed variable a'));
      });

      test('changing a variable type is a MAJOR change', () async {
        final before = 'int a = 1;';
        final after = 'String a = "hello";';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Variable a changed type from int to String'));
      });

      test('changing a variable to final is a MAJOR change', () async {
        final before = 'int a = 1;';
        final after = 'final int a = 1;';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons, contains('MAJOR: Variable a was changed to final'));
      });
    });

    group('Field changes', () {
      test('adding a field is a MINOR change', () async {
        final before = 'class C {}';
        final after = 'class C { int a = 1; }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons, contains('MINOR: Added field a to class C'));
      });

      test('removing a field is a MAJOR change', () async {
        final before = 'class C { int a = 1; }';
        final after = 'class C {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Removed field a from class C'));
      });

      test('changing a field type is a MAJOR change', () async {
        final before = 'class C { int a = 1; }';
        final after = 'class C { String a = "hello"; }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Field a in class C changed type from int to String'));
      });

      test('changing a field to final is a MAJOR change', () async {
        final before = 'class C { int a = 1; }';
        final after = 'class C { final int a = 1; }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Field a in class C was changed to final'));
      });
    });

    group('Enum changes', () {
      test('adding an enum is a MINOR change', () async {
        final before = '';
        final after = 'enum E { a }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons, contains('MINOR: Added enum E'));
      });

      test('removing an enum is a MAJOR change', () async {
        final before = 'enum E { a }';
        final after = '';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Removed enum E'));
      });

      test('adding a value to an enum is a MINOR change', () async {
        final before = 'enum E { a }';
        final after = 'enum E { a, b }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons, contains('MINOR: Added values to enum E: b'));
      });

      test('removing a value from an enum is a MAJOR change', () async {
        final before = 'enum E { a, b }';
        final after = 'enum E { a }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons, contains('MAJOR: Removed values from enum E: b'));
      });

      test('reordering enum values is a MAJOR change', () async {
        final before = 'enum E { a, b }';
        final after = 'enum E { b, a }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Reordered values in enum E'));
      });

      test('renaming an enum value is a MAJOR change', () async {
        final before = 'enum E { a }';
        final after = 'enum E { b }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons, contains('MAJOR: Removed values from enum E: a'));
        expect(result.reasons, contains('MINOR: Added values to enum E: b'));
      });
    });

    group('Mixin and Extension changes', () {
      test('adding a mixin is a MINOR change', () async {
        final before = '';
        final after = 'mixin M {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons, contains('MINOR: Added mixin M'));
      });

      test('removing a mixin is a MAJOR change', () async {
        final before = 'mixin M {}';
        final after = '';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Removed mixin M'));
      });

      test('adding an extension is a MINOR change', () async {
        final before = '';
        final after = 'extension E on String {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons, contains('MINOR: Added extension E'));
      });

      test('removing an extension is a MAJOR change', () async {
        final before = 'extension E on String {}';
        final after = '';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Removed extension E'));
      });
    });

    group('Class hierarchy changes', () {
      test('changing the superclass is a MAJOR change', () async {
        final before = 'class A {} class B extends A {}';
        final after = 'class C {} class B extends C {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Superclass of class B changed from A to C'));
      });

      test('adding an interface is a MAJOR change', () async {
        final before = 'class A {} class B implements A {}';
        final after = 'class A {} class C {} class B implements A, C {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons, contains('MAJOR: Interfaces of class B changed'));
      });

      test('removing an interface is a MAJOR change', () async {
        final before = 'class A {} class C {} class B implements A, C {}';
        final after = 'class A {} class B implements A {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons, contains('MAJOR: Interfaces of class B changed'));
      });

      test('adding a mixin is a MAJOR change', () async {
        final before = 'mixin M {} class C with M {}';
        final after = 'mixin M {} mixin N {} class C with M, N {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Mixins of class C changed'));
      });

      test('removing a mixin is a MAJOR change', () async {
        final before = 'mixin M {} mixin N {} class C with M, N {}';
        final after = 'mixin M {} class C with M {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Mixins of class C changed'));
      });

      test('making a class abstract is a MAJOR change', () async {
        final before = 'class C {}';
        final after = 'abstract class C {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Class C was made abstract'));
      });
    });

    group('Generic type parameter changes on classes', () {
      test('adding a type parameter is a MAJOR change', () async {
        final before = 'class C {}';
        final after = 'class C<T> {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Changed number of type parameters on class C'));
      });

      test('removing a type parameter is a MAJOR change', () async {
        final before = 'class C<T> {}';
        final after = 'class C {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Changed number of type parameters on class C'));
      });

      test('renaming a type parameter is a MAJOR change', () async {
        final before = 'class C<T> {}';
        final after = 'class C<U> {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Renamed type parameter on class C from T to U'));
      });

      test('adding a bound is a MAJOR change', () async {
        final before = 'class C<T> {}';
        final after = 'class C<T extends num> {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Added more restrictive bound to type parameter T on class C'));
      });

      test('removing a bound is a MINOR change', () async {
        final before = 'class C<T extends num> {}';
        final after = 'class C<T> {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons,
            contains('MINOR: Removed bound from type parameter T on class C'));
      });

      test('changing a bound is a MAJOR change', () async {
        final before = 'class C<T extends num> {}';
        final after = 'class C<T extends String> {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Changed bound on type parameter T on class C from num to String'));
      });
    });

    group('Generic type parameter changes on functions', () {
      test('adding a type parameter is a MAJOR change', () async {
        final before = 'void f() {}';
        final after = 'void f<T>() {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Changed number of type parameters on function f'));
      });

      test('removing a type parameter is a MAJOR change', () async {
        final before = 'void f<T>() {}';
        final after = 'void f() {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Changed number of type parameters on function f'));
      });

      test('renaming a type parameter is a MAJOR change', () async {
        final before = 'void f<T>() {}';
        final after = 'void f<U>() {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Renamed type parameter on function f from T to U'));
      });

      test('adding a bound is a MAJOR change', () async {
        final before = 'void f<T>() {}';
        final after = 'void f<T extends num>() {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Added more restrictive bound to type parameter T on function f'));
      });

      test('removing a bound is a MINOR change', () async {
        final before = 'void f<T extends num>() {}';
        final after = 'void f<T>() {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.minor));
        expect(
            result.reasons,
            contains(
                'MINOR: Removed bound from type parameter T on function f'));
      });

      test('changing a bound is a MAJOR change', () async {
        final before = 'void f<T extends num>() {}';
        final after = 'void f<T extends String>() {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Changed bound on type parameter T on function f from num to String'));
      });
    });

    group('Const value changes', () {
      test('changing a const variable value is a MAJOR change', () async {
        final before = 'const int a = 1;';
        final after = 'const int a = 2;';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Const variable a changed value from 1 to 2'));
      });

      test('changing a const field value is a MAJOR change', () async {
        final before = 'class C { static const int a = 1; }';
        final after = 'class C { static const int a = 2; }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Const field a in class C changed value from 1 to 2'));
      });
    });

    group('Static keyword changes', () {
      test('changing a method to static is a MAJOR change', () async {
        final before = 'class C { void m() {} }';
        final after = 'class C { static void m() {} }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons, contains('MAJOR: Method m changed static scope'));
      });

      test('changing a method from static is a MAJOR change', () async {
        final before = 'class C { static void m() {} }';
        final after = 'class C { void m() {} }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons, contains('MAJOR: Method m changed static scope'));
      });

      test('changing a field to static is a MAJOR change', () async {
        final before = 'class C { int a = 1; }';
        final after = 'class C { static int a = 1; }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Field a in class C changed static scope'));
      });

      test('changing a field from static is a MAJOR change', () async {
        final before = 'class C { static int a = 1; }';
        final after = 'class C { int a = 1; }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Field a in class C changed static scope'));
      });
    });

    group('Constructor changes', () {
      test('adding a constructor is a MINOR change', () async {
        final before = 'class C {}';
        final after = 'class C { C.named(); }';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons,
            contains('MINOR: Added constructor named to class C'));
      });

      test('removing a constructor is a MAJOR change', () async {
        final before = 'class C { C.named(); }';
        final after = 'class C {}';
        final result = await diff(before, after);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Removed constructor named from class C'));
      });
    });
  });
}

Future<DiffResult> diff(String beforeCode, String afterCode) async {
  // Use a shared temp directory for all tests
  final tempDir = Directory.systemTemp
      .listSync()
      .firstWhere((e) => e.path.contains('change_detector_test'));

  // Set up "before" project
  final beforeDir = Directory(p.join(tempDir.path, 'before'))
    ..createSync(recursive: true);
  final beforeFile = _createTestProject(beforeDir, beforeCode);

  // Set up "after" project
  final afterDir = Directory(p.join(tempDir.path, 'after'))
    ..createSync(recursive: true);
  final afterFile = _createTestProject(afterDir, afterCode);

  // Generate checksums
  final generator = ApiGenerator();
  final beforeResult = await resolveFile2(path: beforeFile.path);
  final beforeApi =
      generator.generateApi((beforeResult as ResolvedUnitResult).unit);
  final afterResult = await resolveFile2(path: afterFile.path);
  final afterApi =
      generator.generateApi((afterResult as ResolvedUnitResult).unit);

  // Compare and return
  final differ = ApiDiffer();
  return differ.compare(beforeApi!, afterApi!);
}

File _createTestProject(Directory dir, String code) {
  final libDir = Directory(p.join(dir.path, 'lib'))..createSync();
  final libFile = File(p.join(libDir.path, 'test_lib.dart'))
    ..writeAsStringSync(code);
  File(p.join(dir.path, 'pubspec.yaml')).writeAsStringSync('''
name: test_project
environment:
  sdk: '>=2.12.0 <3.0.0'
''');
  return libFile;
}
