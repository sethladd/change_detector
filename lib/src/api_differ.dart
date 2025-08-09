import 'package:change_detector/src/api_checksum.dart';
import 'package:collection/collection.dart';

enum ChangeType {
  major,
  minor,
  none,
}

class DiffResult {
  final ChangeType changeType;
  final List<String> reasons;

  DiffResult(this.changeType, this.reasons);
}

class ApiDiffer {
  DiffResult compare(Api oldApi, Api newApi) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldClasses = {for (var c in oldApi.classes) c.name: c};
    final newClasses = {for (var c in newApi.classes) c.name: c};

    for (final oldClass in oldApi.classes) {
      final newClass = newClasses[oldClass.name];
      if (newClass == null) {
        reasons.add('MAJOR: Removed class ${oldClass.name}');
        changeType = ChangeType.major;
      } else {
        final classDiff = _compareClasses(oldClass, newClass);
        if (classDiff.changeType == ChangeType.major) {
          changeType = ChangeType.major;
        } else if (classDiff.changeType == ChangeType.minor &&
            changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
        reasons.addAll(classDiff.reasons);
      }
    }

    for (final newClass in newApi.classes) {
      if (!oldClasses.containsKey(newClass.name)) {
        reasons.add('MINOR: Added class ${newClass.name}');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      }
    }

    final functionDiff = _compareFunctions(oldApi, newApi);
    if (functionDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (functionDiff.changeType == ChangeType.minor &&
        changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(functionDiff.reasons);

    final variableDiff = _compareVariables(oldApi, newApi);
    if (variableDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (variableDiff.changeType == ChangeType.minor &&
        changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(variableDiff.reasons);

    final enumDiff = _compareEnums(oldApi, newApi);
    if (enumDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (enumDiff.changeType == ChangeType.minor &&
        changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(enumDiff.reasons);

    final mixinDiff = _compareMixins(oldApi, newApi);
    if (mixinDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (mixinDiff.changeType == ChangeType.minor && changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(mixinDiff.reasons);

    final extensionDiff = _compareExtensions(oldApi, newApi);
    if (extensionDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (extensionDiff.changeType == ChangeType.minor && changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(extensionDiff.reasons);

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareMixins(Api oldApi, Api newApi) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldMixins = { for (var m in oldApi.mixins) m.name: m };
    final newMixins = { for (var m in newApi.mixins) m.name: m };

    for (final oldMixin in oldApi.mixins) {
      if (!newMixins.containsKey(oldMixin.name)) {
        reasons.add('MAJOR: Removed mixin ${oldMixin.name}');
        changeType = ChangeType.major;
      }
    }

    for (final newMixin in newApi.mixins) {
      if (!oldMixins.containsKey(newMixin.name)) {
        reasons.add('MINOR: Added mixin ${newMixin.name}');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      }
    }

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareExtensions(Api oldApi, Api newApi) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldExtensions = { for (var e in oldApi.extensions) e.name: e };
    final newExtensions = { for (var e in newApi.extensions) e.name: e };

    for (final oldExtension in oldApi.extensions) {
      if (!newExtensions.containsKey(oldExtension.name)) {
        reasons.add('MAJOR: Removed extension ${oldExtension.name}');
        changeType = ChangeType.major;
      }
    }

    for (final newExtension in newApi.extensions) {
      if (!oldExtensions.containsKey(newExtension.name)) {
        reasons.add('MINOR: Added extension ${newExtension.name}');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      }
    }

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareClasses(ClassApi oldClass, ClassApi newClass) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldMethods = {for (var m in oldClass.methods) m.name: m};
    final newMethods = {for (var m in newClass.methods) m.name: m};

    for (final oldMethod in oldClass.methods) {
      final newMethod = newMethods[oldMethod.name];
      if (newMethod == null) {
        reasons.add(
            'MAJOR: Removed method ${oldMethod.name} from class ${oldClass.name}');
        changeType = ChangeType.major;
      } else {
        final methodDiff = _compareMethods(oldMethod, newMethod);
        if (methodDiff.changeType == ChangeType.major) {
          changeType = ChangeType.major;
        } else if (methodDiff.changeType == ChangeType.minor &&
            changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
        reasons.addAll(methodDiff.reasons);
      }
    }

    for (final newMethod in newClass.methods) {
      if (!oldMethods.containsKey(newMethod.name)) {
        reasons.add(
            'MINOR: Added method ${newMethod.name} to class ${oldClass.name}');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      }
    }

    final fieldDiff = _compareFields(oldClass, newClass);
    if (fieldDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (fieldDiff.changeType == ChangeType.minor &&
        changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(fieldDiff.reasons);

    if (oldClass.superclass != newClass.superclass) {
      reasons.add(
          'MAJOR: Superclass of class ${oldClass.name} changed from ${oldClass.superclass} to ${newClass.superclass}');
      changeType = ChangeType.major;
    }

    if (!const DeepCollectionEquality()
        .equals(oldClass.interfaces, newClass.interfaces)) {
      reasons.add('MAJOR: Interfaces of class ${oldClass.name} changed');
      changeType = ChangeType.major;
    }

    if (!const DeepCollectionEquality()
        .equals(oldClass.mixins, newClass.mixins)) {
      reasons.add('MAJOR: Mixins of class ${oldClass.name} changed');
      changeType = ChangeType.major;
    }

    if (!oldClass.isAbstract && newClass.isAbstract) {
      reasons.add('MAJOR: Class ${oldClass.name} was made abstract');
      changeType = ChangeType.major;
    }

    final typeParameterDiff = _compareTypeParameters(
      oldClass.typeParameters,
      newClass.typeParameters,
      'class ${oldClass.name}',
    );
    if (typeParameterDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (typeParameterDiff.changeType == ChangeType.minor &&
        changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(typeParameterDiff.reasons);

    final constructorDiff = _compareConstructors(oldClass, newClass);
    if (constructorDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (constructorDiff.changeType == ChangeType.minor && changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(constructorDiff.reasons);

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareConstructors(ClassApi oldClass, ClassApi newClass) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldConstructors = { for (var c in oldClass.constructors) c.name: c };
    final newConstructors = { for (var c in newClass.constructors) c.name: c };

    for (final oldConstructor in oldClass.constructors) {
      if (!newConstructors.containsKey(oldConstructor.name)) {
        reasons.add('MAJOR: Removed constructor ${oldConstructor.name} from class ${oldClass.name}');
        changeType = ChangeType.major;
      }
    }

    for (final newConstructor in newClass.constructors) {
      if (!oldConstructors.containsKey(newConstructor.name)) {
        reasons.add('MINOR: Added constructor ${newConstructor.name} to class ${oldClass.name}');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      }
    }

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareTypeParameters(
    List<TypeParameterApi> oldParams,
    List<TypeParameterApi> newParams,
    String context,
  ) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    if (oldParams.length != newParams.length) {
      reasons.add('MAJOR: Changed number of type parameters on $context');
      changeType = ChangeType.major;
      // Don't bother comparing further if the number of params changed.
      return DiffResult(changeType, reasons);
    }

    for (var i = 0; i < oldParams.length; i++) {
      final oldParam = oldParams[i];
      final newParam = newParams[i];

      if (oldParam.name != newParam.name) {
        reasons.add(
            'MAJOR: Renamed type parameter on $context from ${oldParam.name} to ${newParam.name}');
        changeType = ChangeType.major;
      }

      if (oldParam.bound != newParam.bound) {
        if (oldParam.bound == null) {
          reasons.add(
              'MAJOR: Added more restrictive bound to type parameter ${oldParam.name} on $context');
          changeType = ChangeType.major;
        } else if (newParam.bound == null) {
          reasons.add(
              'MINOR: Removed bound from type parameter ${oldParam.name} on $context');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        } else {
          // For now, any change to a bound is considered major.
          // A more sophisticated check would involve checking for sub/supertypes.
          reasons.add(
              'MAJOR: Changed bound on type parameter ${oldParam.name} on $context from ${oldParam.bound} to ${newParam.bound}');
          changeType = ChangeType.major;
        }
      }
    }

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareFunctions(Api oldApi, Api newApi) {
    // This logic is very similar to _compareClasses and _compareMethods, but for top-level functions
    // For now, let's just check for added/removed functions
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldFunctions = {for (var f in oldApi.functions) f.name: f};
    final newFunctions = {for (var f in newApi.functions) f.name: f};

    for (final oldFunction in oldApi.functions) {
      final newFunction = newFunctions[oldFunction.name];
      if (newFunction == null) {
        reasons.add('MAJOR: Removed function ${oldFunction.name}');
        changeType = ChangeType.major;
      } else {
        final functionDiff =
            _compareFunctionSignatures(oldFunction, newFunction);
        if (functionDiff.changeType == ChangeType.major) {
          changeType = ChangeType.major;
        } else if (functionDiff.changeType == ChangeType.minor &&
            changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
        reasons.addAll(functionDiff.reasons);
      }
    }

    for (final newFunction in newApi.functions) {
      if (!oldFunctions.containsKey(newFunction.name)) {
        reasons.add('MINOR: Added function ${newFunction.name}');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      }
    }

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareFunctionSignatures(
      FunctionApi oldFunc, FunctionApi newFunc) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    if (oldFunc.returnType != newFunc.returnType) {
      reasons.add(
          'MAJOR: function ${oldFunc.name} return type changed from ${oldFunc.returnType} to ${newFunc.returnType}');
      changeType = ChangeType.major;
    }

    final paramDiff = _compareFunctionParameters(oldFunc, newFunc);
    if (paramDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (paramDiff.changeType == ChangeType.minor &&
        changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(paramDiff.reasons);

    final typeParameterDiff = _compareTypeParameters(
      oldFunc.typeParameters,
      newFunc.typeParameters,
      'function ${oldFunc.name}',
    );
    if (typeParameterDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (typeParameterDiff.changeType == ChangeType.minor &&
        changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(typeParameterDiff.reasons);

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareEnums(Api oldApi, Api newApi) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldEnums = {for (var e in oldApi.enums) e.name: e};
    final newEnums = {for (var e in newApi.enums) e.name: e};

    for (final oldEnum in oldApi.enums) {
      final newEnum = newEnums[oldEnum.name];
      if (newEnum == null) {
        reasons.add('MAJOR: Removed enum ${oldEnum.name}');
        changeType = ChangeType.major;
      } else {
        if (!const DeepCollectionEquality()
            .equals(oldEnum.values, newEnum.values)) {
          final oldValues = oldEnum.values.toSet();
          final newValues = newEnum.values.toSet();

          final added = newValues.difference(oldValues);
          final removed = oldValues.difference(newValues);

          if (removed.isNotEmpty) {
            reasons.add(
                'MAJOR: Removed values from enum ${oldEnum.name}: ${removed.join(', ')}');
            changeType = ChangeType.major;
          }
          if (added.isNotEmpty) {
            reasons.add(
                'MINOR: Added values to enum ${oldEnum.name}: ${added.join(', ')}');
            if (changeType == ChangeType.none) {
              changeType = ChangeType.minor;
            }
          }

          if (added.isEmpty && removed.isEmpty) {
            reasons.add('MAJOR: Reordered values in enum ${oldEnum.name}');
            changeType = ChangeType.major;
          }
        }
      }
    }

    for (final newEnum in newApi.enums) {
      if (!oldEnums.containsKey(newEnum.name)) {
        reasons.add('MINOR: Added enum ${newEnum.name}');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      }
    }

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareFields(ClassApi oldClass, ClassApi newClass) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldFields = {for (var f in oldClass.fields) f.name: f};
    final newFields = {for (var f in newClass.fields) f.name: f};

    for (final oldField in oldClass.fields) {
      final newField = newFields[oldField.name];
      if (newField == null) {
        reasons.add(
            'MAJOR: Removed field ${oldField.name} from class ${oldClass.name}');
        changeType = ChangeType.major;
      } else {
        if (oldField.type != newField.type) {
          reasons.add(
              'MAJOR: Field ${oldField.name} in class ${oldClass.name} changed type from ${oldField.type} to ${newField.type}');
          changeType = ChangeType.major;
        }
        if (!oldField.isFinal && newField.isFinal) {
          reasons.add(
              'MAJOR: Field ${oldField.name} in class ${oldClass.name} was changed to final');
          changeType = ChangeType.major;
        }
        if (oldField.isConst &&
            newField.isConst &&
            oldField.constValue != newField.constValue) {
          reasons.add(
              'MAJOR: Const field ${oldField.name} in class ${oldClass.name} changed value from ${oldField.constValue} to ${newField.constValue}');
          changeType = ChangeType.major;
        }
      }
    }

    for (final newField in newClass.fields) {
      if (!oldFields.containsKey(newField.name)) {
        reasons.add(
            'MINOR: Added field ${newField.name} to class ${oldClass.name}');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      }
    }

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareVariables(Api oldApi, Api newApi) {
    // This logic is for comparing top-level variables
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldVariables = {for (var v in oldApi.variables) v.name: v};
    final newVariables = {for (var v in newApi.variables) v.name: v};

    for (final oldVariable in oldApi.variables) {
      final newVariable = newVariables[oldVariable.name];
      if (newVariable == null) {
        reasons.add('MAJOR: Removed variable ${oldVariable.name}');
        changeType = ChangeType.major;
      } else {
        if (oldVariable.type != newVariable.type) {
          reasons.add(
              'MAJOR: Variable ${oldVariable.name} changed type from ${oldVariable.type} to ${newVariable.type}');
          changeType = ChangeType.major;
        }
        if (!oldVariable.isFinal && newVariable.isFinal) {
          reasons
              .add('MAJOR: Variable ${oldVariable.name} was changed to final');
          changeType = ChangeType.major;
        }
        if (oldVariable.isConst &&
            newVariable.isConst &&
            oldVariable.constValue != newVariable.constValue) {
          reasons.add(
              'MAJOR: Const variable ${oldVariable.name} changed value from ${oldVariable.constValue} to ${newVariable.constValue}');
          changeType = ChangeType.major;
        }
      }
    }

    for (final newVariable in newApi.variables) {
      if (!oldVariables.containsKey(newVariable.name)) {
        reasons.add('MINOR: Added variable ${newVariable.name}');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      }
    }

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareMethods(MethodApi oldMethod, MethodApi newMethod) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    if (oldMethod.returnType != newMethod.returnType) {
      reasons.add(
          'MAJOR: Method ${oldMethod.name} return type changed from ${oldMethod.returnType} to ${newMethod.returnType}');
      changeType = ChangeType.major;
    }

    final paramDiff = _compareParameters(oldMethod, newMethod);
    if (paramDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (paramDiff.changeType == ChangeType.minor &&
        changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(paramDiff.reasons);

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareFunctionParameters(
      FunctionApi oldFunc, FunctionApi newFunc) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldParams = {for (var p in oldFunc.parameters) p.name: p};
    final newParams = {for (var p in newFunc.parameters) p.name: p};

    for (final oldParam in oldFunc.parameters) {
      final newParam = newParams[oldParam.name];
      if (newParam == null) {
        if (oldParam.kind == ParameterKind.named) {
          // If a named parameter is removed, it could be a rename.
          // We'll check for a new parameter with the same type and kind.
          final replacement = newParams.values.firstWhereOrNull((p) =>
              p.type == oldParam.type &&
              p.kind == oldParam.kind &&
              !oldParams.containsKey(p.name));
          if (replacement != null) {
            reasons.add(
                'MAJOR: Named parameter ${oldParam.name} in function ${oldFunc.name} was renamed to ${replacement.name}');
          } else {
            reasons.add(
                'MAJOR: Removed parameter ${oldParam.name} from function ${oldFunc.name}');
          }
        } else {
          reasons.add(
              'MAJOR: Removed parameter ${oldParam.name} from function ${oldFunc.name}');
        }
        changeType = ChangeType.major;
        continue;
      }

      if (oldParam.kind != newParam.kind) {
        reasons.add(
            'MAJOR: Parameter ${oldParam.name} in function ${oldFunc.name} changed kind from ${oldParam.kind.name} to ${newParam.kind.name}');
        changeType = ChangeType.major;
      } else if (oldParam.type != newParam.type) {
        reasons.add(
            'MAJOR: Parameter ${oldParam.name} in function ${oldFunc.name} changed type from ${oldParam.type} to ${newParam.type}');
        changeType = ChangeType.major;
      } else if (!oldParam.isRequired && newParam.isRequired) {
        reasons.add(
            'MAJOR: Parameter ${oldParam.name} in function ${oldFunc.name} changed from optional to required');
        changeType = ChangeType.major;
      } else if (oldParam.isRequired && !newParam.isRequired) {
        reasons.add(
            'MINOR: Parameter ${oldParam.name} in function ${oldFunc.name} changed from required to optional');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      }
    }

    for (final newParam in newFunc.parameters) {
      if (!oldParams.containsKey(newParam.name)) {
        // This is a new parameter. Check if it's a rename.
        final isRename = oldFunc.parameters.any((p) =>
            p.type == newParam.type &&
            p.kind == newParam.kind &&
            !newParams.containsKey(p.name));
        if (isRename) continue;

        if (newParam.isRequired) {
          reasons.add(
              'MAJOR: Added required parameter ${newParam.name} to function ${oldFunc.name}');
          changeType = ChangeType.major;
        } else {
          reasons.add(
              'MINOR: Added optional parameter ${newParam.name} to function ${oldFunc.name}');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        }
      }
    }

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareParameters(MethodApi oldMethod, MethodApi newMethod) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldParams = {for (var p in oldMethod.parameters) p.name: p};
    final newParams = {for (var p in newMethod.parameters) p.name: p};

    for (final oldParam in oldMethod.parameters) {
      final newParam = newParams[oldParam.name];
      if (newParam == null) {
        if (oldParam.kind == ParameterKind.named) {
          // If a named parameter is removed, it could be a rename.
          // We'll check for a new parameter with the same type and kind.
          final replacement = newParams.values.firstWhereOrNull((p) =>
              p.type == oldParam.type &&
              p.kind == oldParam.kind &&
              !oldParams.containsKey(p.name));
          if (replacement != null) {
            reasons.add(
                'MAJOR: Named parameter ${oldParam.name} in method ${oldMethod.name} was renamed to ${replacement.name}');
          } else {
            reasons.add(
                'MAJOR: Removed parameter ${oldParam.name} from method ${oldMethod.name}');
          }
        } else {
          reasons.add(
              'MAJOR: Removed parameter ${oldParam.name} from method ${oldMethod.name}');
        }
        changeType = ChangeType.major;
        continue;
      }

      if (oldParam.kind != newParam.kind) {
        reasons.add(
            'MAJOR: Parameter ${oldParam.name} in method ${oldMethod.name} changed kind from ${oldParam.kind.name} to ${newParam.kind.name}');
        changeType = ChangeType.major;
      } else if (oldParam.type != newParam.type) {
        reasons.add(
            'MAJOR: Parameter ${oldParam.name} in method ${oldMethod.name} changed type from ${oldParam.type} to ${newParam.type}');
        changeType = ChangeType.major;
      } else if (!oldParam.isRequired && newParam.isRequired) {
        reasons.add(
            'MAJOR: Parameter ${oldParam.name} in method ${oldMethod.name} changed from optional to required');
        changeType = ChangeType.major;
      } else if (oldParam.isRequired && !newParam.isRequired) {
        reasons.add(
            'MINOR: Parameter ${oldParam.name} in method ${oldMethod.name} changed from required to optional');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      }
    }

    for (final newParam in newMethod.parameters) {
      if (!oldParams.containsKey(newParam.name)) {
        // This is a new parameter. Check if it's a rename.
        final isRename = oldMethod.parameters.any((p) =>
            p.type == newParam.type &&
            p.kind == newParam.kind &&
            !newParams.containsKey(p.name));
        if (isRename) continue;

        if (newParam.isRequired) {
          reasons.add(
              'MAJOR: Added required parameter ${newParam.name} to method ${oldMethod.name}');
          changeType = ChangeType.major;
        } else {
          reasons.add(
              'MINOR: Added optional parameter ${newParam.name} to method ${oldMethod.name}');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        }
      }
    }

    return DiffResult(changeType, reasons);
  }
}

extension StringCapitalize on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
