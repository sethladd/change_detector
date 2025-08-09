import 'package:change_detector/src/api_checksum.dart';
import 'package:change_detector/src/api_differ.dart';
import 'package:test/test.dart';

void main() {
  group('ApiDiffer', () {
    late ApiDiffer differ;

    setUp(() {
      differ = ApiDiffer();
    });

    test('reports no changes when APIs are identical', () {
      final oldApi = _createApiWithItems();
      final newApi = _createApiWithItems();
      final result = differ.compare(oldApi, newApi);
      expect(result.changeType, equals(ChangeType.none));
      expect(result.reasons, isEmpty);
    });

    group('Parameter changes', () {
      test('adding a required parameter is a MAJOR change', () {
        final oldApi = _createApiWithMethodParams([]);
        final newApi = _createApiWithMethodParams([
          ParameterApi(
              name: 'a',
              type: 'int',
              kind: ParameterKind.positional,
              isRequired: true)
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Added required parameter a to method testMethod'));
      });

      test('adding an optional parameter is a MINOR change', () {
        final oldApi = _createApiWithMethodParams([]);
        final newApi = _createApiWithMethodParams([
          ParameterApi(
              name: 'a',
              type: 'int',
              kind: ParameterKind.positional,
              isRequired: false)
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons,
            contains('MINOR: Added optional parameter a to method testMethod'));
      });

      test('removing a parameter is a MAJOR change', () {
        final oldApi = _createApiWithMethodParams([
          ParameterApi(
              name: 'a',
              type: 'int',
              kind: ParameterKind.positional,
              isRequired: true)
        ]);
        final newApi = _createApiWithMethodParams([]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Removed parameter a from method testMethod'));
      });

      test('changing a parameter type is a MAJOR change', () {
        final oldApi = _createApiWithMethodParams([
          ParameterApi(
              name: 'a',
              type: 'int',
              kind: ParameterKind.positional,
              isRequired: true)
        ]);
        final newApi = _createApiWithMethodParams([
          ParameterApi(
              name: 'a',
              type: 'String',
              kind: ParameterKind.positional,
              isRequired: true)
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Parameter a in method testMethod changed type from int to String'));
      });

      test('changing an optional parameter to required is a MAJOR change', () {
        final oldApi = _createApiWithMethodParams([
          ParameterApi(
              name: 'a',
              type: 'int',
              kind: ParameterKind.positional,
              isRequired: false)
        ]);
        final newApi = _createApiWithMethodParams([
          ParameterApi(
              name: 'a',
              type: 'int',
              kind: ParameterKind.positional,
              isRequired: true)
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Parameter a in method testMethod changed from optional to required'));
      });

      test('changing a required parameter to optional is a MINOR change', () {
        final oldApi = _createApiWithMethodParams([
          ParameterApi(
              name: 'a',
              type: 'int',
              kind: ParameterKind.positional,
              isRequired: true)
        ]);
        final newApi = _createApiWithMethodParams([
          ParameterApi(
              name: 'a',
              type: 'int',
              kind: ParameterKind.positional,
              isRequired: false)
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.minor));
        expect(
            result.reasons,
            contains(
                'MINOR: Parameter a in method testMethod changed from required to optional'));
      });

      test('renaming a named parameter is a MAJOR change', () {
        final oldApi = _createApiWithMethodParams([
          ParameterApi(
              name: 'a',
              type: 'int',
              kind: ParameterKind.named,
              isRequired: true)
        ]);
        final newApi = _createApiWithMethodParams([
          ParameterApi(
              name: 'b',
              type: 'int',
              kind: ParameterKind.named,
              isRequired: true)
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Named parameter a in method testMethod was renamed to b'));
      });
    });

    group('Top-level declaration changes', () {
      test('adding a function is a MINOR change', () {
        final oldApi = _createApiWithItems();
        final newApi = _createApiWithItems(
          functions: [
            FunctionApi(
                name: 'testFunction',
                returnType: 'void',
                parameters: [],
                typeParameters: [])
          ],
        );
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons, contains('MINOR: Added function testFunction'));
      });

      test('removing a function is a MAJOR change', () {
        final oldApi = _createApiWithItems(
          functions: [
            FunctionApi(
                name: 'testFunction',
                returnType: 'void',
                parameters: [],
                typeParameters: [])
          ],
        );
        final newApi = _createApiWithItems();
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons, contains('MAJOR: Removed function testFunction'));
      });

      test('adding a variable is a MINOR change', () {
        final oldApi = _createApiWithItems();
        final newApi = _createApiWithItems(
          variables: [
            VariableApi(
                name: 'testVar', type: 'int', isFinal: false, isConst: false)
          ],
        );
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons, contains('MINOR: Added variable testVar'));
      });

      test('removing a variable is a MAJOR change', () {
        final oldApi = _createApiWithItems(
          variables: [
            VariableApi(
                name: 'testVar', type: 'int', isFinal: false, isConst: false)
          ],
        );
        final newApi = _createApiWithItems();
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Removed variable testVar'));
      });

      test('changing a variable type is a MAJOR change', () {
        final oldApi = _createApiWithItems(
          variables: [
            VariableApi(
                name: 'testVar', type: 'int', isFinal: false, isConst: false)
          ],
        );
        final newApi = _createApiWithItems(
          variables: [
            VariableApi(
                name: 'testVar', type: 'String', isFinal: false, isConst: false)
          ],
        );
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Variable testVar changed type from int to String'));
      });

      test('changing a variable to final is a MAJOR change', () {
        final oldApi = _createApiWithItems(
          variables: [
            VariableApi(
                name: 'testVar', type: 'int', isFinal: false, isConst: false)
          ],
        );
        final newApi = _createApiWithItems(
          variables: [
            VariableApi(
                name: 'testVar', type: 'int', isFinal: true, isConst: false)
          ],
        );
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Variable testVar was changed to final'));
      });
    });

    group('Field changes', () {
      test('adding a field is a MINOR change', () {
        final oldApi = _createApiWithClassAndFields([]);
        final newApi = _createApiWithClassAndFields([
          FieldApi(name: 'testField', type: 'int', isFinal: false, isConst: false, isStatic: false)
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons, contains('MINOR: Added field testField to class TestClass'));
      });

      test('removing a field is a MAJOR change', () {
        final oldApi = _createApiWithClassAndFields([
          FieldApi(name: 'testField', type: 'int', isFinal: false, isConst: false, isStatic: false)
        ]);
        final newApi = _createApiWithClassAndFields([]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Removed field testField from class TestClass'));
      });

      test('changing a field type is a MAJOR change', () {
        final oldApi = _createApiWithClassAndFields([
          FieldApi(name: 'testField', type: 'int', isFinal: false, isConst: false, isStatic: false)
        ]);
        final newApi = _createApiWithClassAndFields([
          FieldApi(name: 'testField', type: 'String', isFinal: false, isConst: false, isStatic: false)
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Field testField in class TestClass changed type from int to String'));
      });

      test('changing a field to final is a MAJOR change', () {
        final oldApi = _createApiWithClassAndFields([
          FieldApi(name: 'testField', type: 'int', isFinal: false, isConst: false, isStatic: false)
        ]);
        final newApi = _createApiWithClassAndFields([
          FieldApi(name: 'testField', type: 'int', isFinal: true, isConst: false, isStatic: false)
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Field testField in class TestClass was changed to final'));
      });
    });

    group('Enum changes', () {
      test('adding an enum is a MINOR change', () {
        final oldApi = _createApiWithItems();
        final newApi = _createApiWithItems(enums: [
          EnumApi(name: 'TestEnum', values: ['a'])
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons, contains('MINOR: Added enum TestEnum'));
      });

      test('removing an enum is a MAJOR change', () {
        final oldApi = _createApiWithItems(enums: [
          EnumApi(name: 'TestEnum', values: ['a'])
        ]);
        final newApi = _createApiWithItems();
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Removed enum TestEnum'));
      });

      test('adding a value to an enum is a MINOR change', () {
        final oldApi = _createApiWithEnumValues(['a']);
        final newApi = _createApiWithEnumValues(['a', 'b']);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons,
            contains('MINOR: Added values to enum TestEnum: b'));
      });

      test('removing a value from an enum is a MAJOR change', () {
        final oldApi = _createApiWithEnumValues(['a', 'b']);
        final newApi = _createApiWithEnumValues(['a']);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Removed values from enum TestEnum: b'));
      });

      test('reordering enum values is a MAJOR change', () {
        final oldApi = _createApiWithEnumValues(['a', 'b']);
        final newApi = _createApiWithEnumValues(['b', 'a']);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Reordered values in enum TestEnum'));
      });

      test('renaming an enum value is a MAJOR change', () {
        final oldApi = _createApiWithEnumValues(['a']);
        final newApi = _createApiWithEnumValues(['b']);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Removed values from enum TestEnum: a'));
        expect(result.reasons,
            contains('MINOR: Added values to enum TestEnum: b'));
      });
    });

    group('Class hierarchy changes', () {
      test('changing the superclass is a MAJOR change', () {
        final oldApi = _createApiWithClassHierarchy(superclass: 'OldSuper');
        final newApi = _createApiWithClassHierarchy(superclass: 'NewSuper');
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Superclass of class TestClass changed from OldSuper to NewSuper'));
      });

      test('adding an interface is a MAJOR change', () {
        final oldApi =
            _createApiWithClassHierarchy(interfaces: ['OldInterface']);
        final newApi = _createApiWithClassHierarchy(
            interfaces: ['OldInterface', 'NewInterface']);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Interfaces of class TestClass changed'));
      });

      test('removing an interface is a MAJOR change', () {
        final oldApi = _createApiWithClassHierarchy(
            interfaces: ['OldInterface', 'NewInterface']);
        final newApi =
            _createApiWithClassHierarchy(interfaces: ['OldInterface']);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Interfaces of class TestClass changed'));
      });

      test('adding a mixin is a MAJOR change', () {
        final oldApi = _createApiWithClassHierarchy(mixins: ['OldMixin']);
        final newApi =
            _createApiWithClassHierarchy(mixins: ['OldMixin', 'NewMixin']);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Mixins of class TestClass changed'));
      });

      test('removing a mixin is a MAJOR change', () {
        final oldApi =
            _createApiWithClassHierarchy(mixins: ['OldMixin', 'NewMixin']);
        final newApi = _createApiWithClassHierarchy(mixins: ['OldMixin']);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Mixins of class TestClass changed'));
      });

      test('making a class abstract is a MAJOR change', () {
        final oldApi = _createApiWithClassHierarchy(isAbstract: false);
        final newApi = _createApiWithClassHierarchy(isAbstract: true);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons,
            contains('MAJOR: Class TestClass was made abstract'));
      });
    });

    group('Mixin and Extension changes', () {
      test('adding a mixin is a MINOR change', () {
        final oldApi = _createApiWithItems();
        final newApi =
            _createApiWithItems(mixins: [MixinApi(name: 'TestMixin')]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.minor));
        expect(result.reasons, contains('MINOR: Added mixin TestMixin'));
      });

      test('removing a mixin is a MAJOR change', () {
        final oldApi =
            _createApiWithItems(mixins: [MixinApi(name: 'TestMixin')]);
        final newApi = _createApiWithItems();
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Removed mixin TestMixin'));
      });

      test('adding an extension is a MINOR change', () {
        final oldApi = _createApiWithItems();
        final newApi = _createApiWithItems(
            extensions: [ExtensionApi(name: 'TestExtension')]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.minor));
        expect(
            result.reasons, contains('MINOR: Added extension TestExtension'));
      });

      test('removing an extension is a MAJOR change', () {
        final oldApi = _createApiWithItems(
            extensions: [ExtensionApi(name: 'TestExtension')]);
        final newApi = _createApiWithItems();
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons, contains('MAJOR: Removed extension TestExtension'));
      });
    });

    group('Generic type parameter changes on classes', () {
      test('adding a type parameter is a MAJOR change', () {
        final oldApi = _createApiWithClassTypeParams([]);
        final newApi =
            _createApiWithClassTypeParams([TypeParameterApi(name: 'T')]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Changed number of type parameters on class TestClass'));
      });

      test('removing a type parameter is a MAJOR change', () {
        final oldApi =
            _createApiWithClassTypeParams([TypeParameterApi(name: 'T')]);
        final newApi = _createApiWithClassTypeParams([]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Changed number of type parameters on class TestClass'));
      });

      test('renaming a type parameter is a MAJOR change', () {
        final oldApi =
            _createApiWithClassTypeParams([TypeParameterApi(name: 'T')]);
        final newApi =
            _createApiWithClassTypeParams([TypeParameterApi(name: 'U')]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Renamed type parameter on class TestClass from T to U'));
      });

      test('adding a bound is a MAJOR change', () {
        final oldApi =
            _createApiWithClassTypeParams([TypeParameterApi(name: 'T')]);
        final newApi = _createApiWithClassTypeParams(
            [TypeParameterApi(name: 'T', bound: 'num')]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Added more restrictive bound to type parameter T on class TestClass'));
      });

      test('removing a bound is a MINOR change', () {
        final oldApi = _createApiWithClassTypeParams(
            [TypeParameterApi(name: 'T', bound: 'num')]);
        final newApi =
            _createApiWithClassTypeParams([TypeParameterApi(name: 'T')]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.minor));
        expect(
            result.reasons,
            contains(
                'MINOR: Removed bound from type parameter T on class TestClass'));
      });

      test('changing a bound is a MAJOR change', () {
        final oldApi = _createApiWithClassTypeParams(
            [TypeParameterApi(name: 'T', bound: 'num')]);
        final newApi = _createApiWithClassTypeParams(
            [TypeParameterApi(name: 'T', bound: 'String')]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Changed bound on type parameter T on class TestClass from num to String'));
      });
    });

    group('Generic type parameter changes on functions', () {
      test('adding a type parameter is a MAJOR change', () {
        final oldApi = _createApiWithFunctionTypeParams([]);
        final newApi =
            _createApiWithFunctionTypeParams([TypeParameterApi(name: 'T')]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Changed number of type parameters on function testFunction'));
      });

      test('removing a type parameter is a MAJOR change', () {
        final oldApi =
            _createApiWithFunctionTypeParams([TypeParameterApi(name: 'T')]);
        final newApi = _createApiWithFunctionTypeParams([]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Changed number of type parameters on function testFunction'));
      });

      test('renaming a type parameter is a MAJOR change', () {
        final oldApi =
            _createApiWithFunctionTypeParams([TypeParameterApi(name: 'T')]);
        final newApi =
            _createApiWithFunctionTypeParams([TypeParameterApi(name: 'U')]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Renamed type parameter on function testFunction from T to U'));
      });

      test('adding a bound is a MAJOR change', () {
        final oldApi =
            _createApiWithFunctionTypeParams([TypeParameterApi(name: 'T')]);
        final newApi = _createApiWithFunctionTypeParams(
            [TypeParameterApi(name: 'T', bound: 'num')]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Added more restrictive bound to type parameter T on function testFunction'));
      });

      test('removing a bound is a MINOR change', () {
        final oldApi = _createApiWithFunctionTypeParams(
            [TypeParameterApi(name: 'T', bound: 'num')]);
        final newApi =
            _createApiWithFunctionTypeParams([TypeParameterApi(name: 'T')]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.minor));
        expect(
            result.reasons,
            contains(
                'MINOR: Removed bound from type parameter T on function testFunction'));
      });

      test('changing a bound is a MAJOR change', () {
        final oldApi = _createApiWithFunctionTypeParams(
            [TypeParameterApi(name: 'T', bound: 'num')]);
        final newApi = _createApiWithFunctionTypeParams(
            [TypeParameterApi(name: 'T', bound: 'String')]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Changed bound on type parameter T on function testFunction from num to String'));
      });
    });

    group('Const value changes', () {
      test('changing a const variable value is a MAJOR change', () {
        final oldApi = _createApiWithItems(
          variables: [
            VariableApi(
                name: 'testVar',
                type: 'int',
                isFinal: false,
                isConst: true,
                constValue: '1')
          ],
        );
        final newApi = _createApiWithItems(
          variables: [
            VariableApi(
                name: 'testVar',
                type: 'int',
                isFinal: false,
                isConst: true,
                constValue: '2')
          ],
        );
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Const variable testVar changed value from 1 to 2'));
      });

      test('changing a const field value is a MAJOR change', () {
        final oldApi = _createApiWithClassAndFields([
          FieldApi(name: 'testField', type: 'int', isFinal: false, isConst: true, constValue: '1', isStatic: false)
        ]);
        final newApi = _createApiWithClassAndFields([
          FieldApi(name: 'testField', type: 'int', isFinal: false, isConst: true, constValue: '2', isStatic: false)
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Const field testField in class TestClass changed value from 1 to 2'));
      });
    });

    group('Static keyword changes', () {
      test('changing a method to static is a MAJOR change', () {
        final oldApi = _createApiWithMethodParams([], isStatic: false);
        final newApi = _createApiWithMethodParams([], isStatic: true);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Method testMethod changed static scope'));
      });

      test('changing a method from static is a MAJOR change', () {
        final oldApi = _createApiWithMethodParams([], isStatic: true);
        final newApi = _createApiWithMethodParams([], isStatic: false);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Method testMethod changed static scope'));
      });

      test('changing a field to static is a MAJOR change', () {
        final oldApi = _createApiWithClassAndFields([
          FieldApi(name: 'testField', type: 'int', isFinal: false, isConst: false, isStatic: false)
        ]);
        final newApi = _createApiWithClassAndFields([
          FieldApi(name: 'testField', type: 'int', isFinal: false, isConst: false, isStatic: true)
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Field testField in class TestClass changed static scope'));
      });

      test('changing a field from static is a MAJOR change', () {
        final oldApi = _createApiWithClassAndFields([
          FieldApi(name: 'testField', type: 'int', isFinal: false, isConst: false, isStatic: true)
        ]);
        final newApi = _createApiWithClassAndFields([
          FieldApi(name: 'testField', type: 'int', isFinal: false, isConst: false, isStatic: false)
        ]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(result.reasons, contains('MAJOR: Field testField in class TestClass changed static scope'));
      });
    });

    group('Constructor changes', () {
      test('adding a constructor is a MINOR change', () {
        final oldApi = _createApiWithConstructors([]);
        final newApi = _createApiWithConstructors(
            [ConstructorApi(name: 'TestConstructor', parameters: [])]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.minor));
        expect(
            result.reasons,
            contains(
                'MINOR: Added constructor TestConstructor to class TestClass'));
      });

      test('removing a constructor is a MAJOR change', () {
        final oldApi = _createApiWithConstructors(
            [ConstructorApi(name: 'TestConstructor', parameters: [])]);
        final newApi = _createApiWithConstructors([]);
        final result = differ.compare(oldApi, newApi);
        expect(result.changeType, equals(ChangeType.major));
        expect(
            result.reasons,
            contains(
                'MAJOR: Removed constructor TestConstructor from class TestClass'));
      });
    });
  });
}

Api _createApiWithMethodParams(List<ParameterApi> params, {bool isStatic = false}) {
  return _createApiWithItems(classes: [
    ClassApi(
      name: 'TestClass',
      methods: [
        MethodApi(
          name: 'testMethod',
          returnType: 'void',
          parameters: params,
          isStatic: isStatic,
        )
      ],
      fields: [],
      constructors: [],
      interfaces: [],
      mixins: [],
      typeParameters: [],
      isAbstract: false,
    )
  ]);
}

Api _createApiWithItems({
  List<ClassApi> classes = const [],
  List<FunctionApi> functions = const [],
  List<VariableApi> variables = const [],
  List<EnumApi> enums = const [],
  List<MixinApi> mixins = const [],
  List<ExtensionApi> extensions = const [],
}) {
  return Api(
    classes: classes,
    functions: functions,
    variables: variables,
    enums: enums,
    mixins: mixins,
    extensions: extensions,
  );
}

Api _createApiWithClassAndFields(List<FieldApi> fields) {
  return _createApiWithItems(classes: [
    ClassApi(
      name: 'TestClass',
      methods: [],
      fields: fields,
      constructors: [],
      interfaces: [],
      mixins: [],
      typeParameters: [],
      isAbstract: false,
    )
  ]);
}

Api _createApiWithEnumValues(List<String> values) {
  return _createApiWithItems(enums: [
    EnumApi(name: 'TestEnum', values: values),
  ]);
}

Api _createApiWithClassHierarchy({
  String? superclass,
  List<String> interfaces = const [],
  List<String> mixins = const [],
  bool isAbstract = false,
}) {
  return _createApiWithItems(classes: [
    ClassApi(
      name: 'TestClass',
      methods: [],
      fields: [],
      constructors: [],
      superclass: superclass,
      interfaces: interfaces,
      mixins: mixins,
      typeParameters: [],
      isAbstract: isAbstract,
    )
  ]);
}

Api _createApiWithClassTypeParams(List<TypeParameterApi> typeParams) {
  return _createApiWithItems(classes: [
    ClassApi(
      name: 'TestClass',
      methods: [],
      fields: [],
      constructors: [],
      superclass: null,
      interfaces: [],
      mixins: [],
      typeParameters: typeParams,
      isAbstract: false,
    )
  ]);
}

Api _createApiWithConstructors(List<ConstructorApi> constructors) {
  return _createApiWithItems(classes: [
    ClassApi(
      name: 'TestClass',
      methods: [],
      fields: [],
      constructors: constructors,
      superclass: null,
      interfaces: [],
      mixins: [],
      typeParameters: [],
      isAbstract: false,
    )
  ]);
}

Api _createApiWithFunctionTypeParams(List<TypeParameterApi> typeParams) {
  return _createApiWithItems(functions: [
    FunctionApi(
      name: 'testFunction',
      returnType: 'void',
      parameters: [],
      typeParameters: typeParams,
    )
  ]);
}
