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

// Helper class to store type parameters for Map
class MapTypeParams {
  final String keyType;
  final String valueType;

  MapTypeParams(this.keyType, this.valueType);
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
        if (!oldClass.isDeprecated && newClass.isDeprecated) {
          reasons.add('MINOR: Class ${oldClass.name} is now deprecated');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        }
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
    } else if (mixinDiff.changeType == ChangeType.minor &&
        changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(mixinDiff.reasons);

    final extensionDiff = _compareExtensions(oldApi, newApi);
    if (extensionDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (extensionDiff.changeType == ChangeType.minor &&
        changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(extensionDiff.reasons);

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareMixins(Api oldApi, Api newApi) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldMixins = {for (var m in oldApi.mixins) m.name: m};
    final newMixins = {for (var m in newApi.mixins) m.name: m};

    for (final oldMixin in oldApi.mixins) {
      final newMixin = newMixins[oldMixin.name];
      if (newMixin == null) {
        reasons.add('MAJOR: Removed mixin ${oldMixin.name}');
        changeType = ChangeType.major;
      } else {
        if (!oldMixin.isDeprecated && newMixin.isDeprecated) {
          reasons.add('MINOR: Mixin ${oldMixin.name} is now deprecated');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        }
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

    final oldExtensions = {for (var e in oldApi.extensions) e.name: e};
    final newExtensions = {for (var e in newApi.extensions) e.name: e};

    for (final oldExtension in oldApi.extensions) {
      final newExtension = newExtensions[oldExtension.name];
      if (newExtension == null) {
        reasons.add('MAJOR: Removed extension ${oldExtension.name}');
        changeType = ChangeType.major;
      } else {
        if (!oldExtension.isDeprecated && newExtension.isDeprecated) {
          reasons
              .add('MINOR: Extension ${oldExtension.name} is now deprecated');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        }
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
        if (!oldMethod.isDeprecated && newMethod.isDeprecated) {
          reasons.add('MINOR: Method ${oldMethod.name} is now deprecated');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        }
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

    // Deep hierarchy analysis
    final hierarchyDiff = _compareClassHierarchies(oldClass, newClass);
    if (hierarchyDiff.changeType == ChangeType.major) {
      changeType = ChangeType.major;
    } else if (hierarchyDiff.changeType == ChangeType.minor &&
        changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(hierarchyDiff.reasons);

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
    } else if (constructorDiff.changeType == ChangeType.minor &&
        changeType == ChangeType.none) {
      changeType = ChangeType.minor;
    }
    reasons.addAll(constructorDiff.reasons);

    return DiffResult(changeType, reasons);
  }

  DiffResult _compareClassHierarchies(ClassApi oldClass, ClassApi newClass) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    // Check direct superclass changes
    if (oldClass.superclass != newClass.superclass) {
      // Basic change was already detected in previous code
      // Now let's analyze if the new superclass is a subtype of the old one
      if (oldClass.superclass != null && newClass.superclass != null) {
        final isSubtype =
            _isSubtypeOf(newClass.superclass!, oldClass.superclass!);
        if (isSubtype) {
          reasons.add(
              'MINOR: Superclass of ${oldClass.name} changed from ${oldClass.superclass} to ${newClass.superclass}, which is a subtype');
          changeType = ChangeType.minor;
        } else {
          reasons.add(
              'MAJOR: Superclass of ${oldClass.name} changed from ${oldClass.superclass} to ${newClass.superclass}, which is not a subtype');
          changeType = ChangeType.major;
        }
      } else {
        // One of the superclasses is null - this is a major change
        reasons.add(
            'MAJOR: Superclass of class ${oldClass.name} changed from ${oldClass.superclass} to ${newClass.superclass}');
        changeType = ChangeType.major;
      }
    }

    // Compare interfaces
    final oldInterfaces = oldClass.interfaces.toSet();
    final newInterfaces = newClass.interfaces.toSet();

    final removedInterfaces = oldInterfaces.difference(newInterfaces);
    final addedInterfaces = newInterfaces.difference(oldInterfaces);

    if (removedInterfaces.isNotEmpty) {
      // Check if any removed interfaces are still covered by inheritance or other interfaces
      for (final removedInterface in removedInterfaces) {
        bool stillCovered = false;
        // Check if the new class inherits this interface through its superclass
        if (newClass.superclass != null) {
          stillCovered =
              _inheritsInterface(newClass.superclass!, removedInterface);
        }

        // Check if any new interface is a subtype of the removed one
        if (!stillCovered) {
          for (final newInterface in newInterfaces) {
            if (_isSubtypeOf(newInterface, removedInterface)) {
              stillCovered = true;
              break;
            }
          }
        }

        if (!stillCovered) {
          reasons.add(
              'MAJOR: Interface $removedInterface was removed from class ${oldClass.name}');
          changeType = ChangeType.major;
        } else {
          reasons.add(
              'MINOR: Interface $removedInterface was removed from class ${oldClass.name} but is still implemented through inheritance');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        }
      }
    }

    if (addedInterfaces.isNotEmpty) {
      reasons.add(
          'MINOR: Added interfaces to class ${oldClass.name}: ${addedInterfaces.join(', ')}');
      if (changeType == ChangeType.none) {
        changeType = ChangeType.minor;
      }
    }

    // Compare mixins
    final oldMixins = oldClass.mixins.toSet();
    final newMixins = newClass.mixins.toSet();

    final removedMixins = oldMixins.difference(newMixins);
    final addedMixins = newMixins.difference(oldMixins);

    if (removedMixins.isNotEmpty) {
      reasons.add(
          'MAJOR: Removed mixins from class ${oldClass.name}: ${removedMixins.join(', ')}');
      changeType = ChangeType.major;
    }

    if (addedMixins.isNotEmpty) {
      // This is a simplified check - a real implementation would need to analyze
      // the members of the mixins to determine potential conflicts
      reasons.add(
          'MINOR: Added mixins to class ${oldClass.name}: ${addedMixins.join(', ')}');
      if (changeType == ChangeType.none) {
        changeType = ChangeType.minor;
      }
    }

    return DiffResult(changeType, reasons);
  }

  // Helper method to check if type A is a subtype of type B
  bool _isSubtypeOf(String typeA, String typeB) {
    // This is a simplified implementation - in a real Dart analyzer implementation,
    // we would use the ElementModel and TypeSystem to properly check subtype relationships

    // For now, handle some common cases:
    if (typeA == typeB) {
      return true;
    }

    // Check some well-known Dart type relationships
    if (typeB == 'Object' || typeB == 'Object?' || typeB == 'dynamic') {
      return true;
    }

    // Handle nullable types (Dart null safety)
    if (typeB.endsWith('?')) {
      final nonNullableB = typeB.substring(0, typeB.length - 1);
      return _isSubtypeOf(typeA, nonNullableB);
    }

    // Handle common built-in types
    final numSubtypes = {'int', 'double', 'int?', 'double?'};
    if ((typeB == 'num' || typeB == 'num?') && numSubtypes.contains(typeA)) {
      return true;
    }

    // Handle common collection types with type parameters
    if (_isGenericSubtype(typeA, typeB)) {
      return true;
    }

    // Special case for Future/FutureOr
    if (typeB.startsWith('FutureOr<') && typeA.startsWith('Future<')) {
      final typeParamB = _extractTypeParam(typeB, 'FutureOr');
      final typeParamA = _extractTypeParam(typeA, 'Future');
      if (typeParamB != null && typeParamA != null) {
        return _isSubtypeOf(typeParamA, typeParamB);
      }
    }

    // For other cases, we can't determine without full type resolution
    return false;
  }

  // Helper method for generic subtypes

  // Helper method to check generic subtype relationships
  bool _isGenericSubtype(String typeA, String typeB) {
    // Handle List, Set, Map, etc.
    final genericTypes = ['List', 'Set', 'Iterable', 'Future'];

    for (final genericType in genericTypes) {
      if (typeB.startsWith('$genericType<') &&
          typeA.startsWith('$genericType<')) {
        final typeParamB = _extractTypeParam(typeB, genericType);
        final typeParamA = _extractTypeParam(typeA, genericType);
        if (typeParamB != null && typeParamA != null) {
          return _isSubtypeOf(typeParamA, typeParamB);
        }
        // If we can't extract the type parameters properly, we can't determine
        return false;
      }
    }

    // Handle Map separately due to two type parameters
    if (typeB.startsWith('Map<') && typeA.startsWith('Map<')) {
      final typeParamsB = _extractMapTypeParams(typeB);
      final typeParamsA = _extractMapTypeParams(typeA);
      if (typeParamsB != null && typeParamsA != null) {
        return _isSubtypeOf(typeParamsA.keyType, typeParamsB.keyType) &&
            _isSubtypeOf(typeParamsA.valueType, typeParamsB.valueType);
      }
    }

    return false;
  }

  // Extract the type parameter from a generic type
  String? _extractTypeParam(String type, String genericType) {
    final pattern = RegExp('^$genericType<(.+)>\$');
    final match = pattern.firstMatch(type);
    return match?.group(1);
  }

  // Extract both type parameters from a Map type
  MapTypeParams? _extractMapTypeParams(String type) {
    final pattern = RegExp('^Map<([^,]+),\\s*([^>]+)>\$');
    final match = pattern.firstMatch(type);
    if (match != null) {
      return MapTypeParams(match.group(1)!, match.group(2)!);
    }
    return null;
  }

  // Helper method to check if a class inherits an interface
  bool _inheritsInterface(String className, String interfaceName) {
    // This is a simplified implementation - in a real implementation,
    // we would traverse the full class hierarchy and check all interfaces

    // Without full access to the type system, we can only approximate
    // common inheritance patterns in Dart

    // Common Dart interface implementations
    final knownImplementations = {
      'List': {'Iterable', 'Collection'},
      'Set': {'Iterable', 'Collection'},
      'Map': {'MapBase', 'Map'},
      'String': {'Comparable', 'Pattern'},
      'Future': {'FutureOr'},
      'Stream': {'StreamView'},
      'Duration': {'Comparable'},
      'DateTime': {'Comparable'},
    };

    final interfaces = knownImplementations[className];
    if (interfaces != null && interfaces.contains(interfaceName)) {
      return true;
    }

    // Check for generic interface implementations
    if (className.contains('<') && interfaceName.contains('<')) {
      final baseClassName = className.split('<')[0];
      final baseInterfaceName = interfaceName.split('<')[0];

      final baseInterfaces = knownImplementations[baseClassName];
      if (baseInterfaces != null &&
          baseInterfaces.contains(baseInterfaceName)) {
        // For complete implementation, we would need to check type parameters too
        return true;
      }
    }

    return false;
  }

  DiffResult _compareConstructors(ClassApi oldClass, ClassApi newClass) {
    final reasons = <String>[];
    var changeType = ChangeType.none;

    final oldConstructors = {for (var c in oldClass.constructors) c.name: c};
    final newConstructors = {for (var c in newClass.constructors) c.name: c};

    for (final oldConstructor in oldClass.constructors) {
      final newConstructor = newConstructors[oldConstructor.name];
      if (newConstructor == null) {
        reasons.add(
            'MAJOR: Removed constructor ${oldConstructor.name} from class ${oldClass.name}');
        changeType = ChangeType.major;
      } else {
        if (!oldConstructor.isDeprecated && newConstructor.isDeprecated) {
          reasons.add(
              'MINOR: Constructor ${oldConstructor.name} is now deprecated');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        }
      }
    }

    for (final newConstructor in newClass.constructors) {
      if (!oldConstructors.containsKey(newConstructor.name)) {
        reasons.add(
            'MINOR: Added constructor ${newConstructor.name} to class ${oldClass.name}');
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
          // Check if the new bound is a supertype of the old bound, which means it's less restrictive
          if (_isSubtypeOf(oldParam.bound!, newParam.bound!)) {
            reasons.add(
                'MINOR: Loosened bound on type parameter ${oldParam.name} on $context from ${oldParam.bound} to ${newParam.bound}');
            if (changeType == ChangeType.none) {
              changeType = ChangeType.minor;
            }
          } else {
            // The bound was tightened or changed to an incompatible type
            reasons.add(
                'MAJOR: Changed bound on type parameter ${oldParam.name} on $context from ${oldParam.bound} to ${newParam.bound}');
            changeType = ChangeType.major;
          }
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
        if (!oldFunction.isDeprecated && newFunction.isDeprecated) {
          reasons.add('MINOR: Function ${oldFunction.name} is now deprecated');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        }
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
      // Check if the new return type is a subtype of the old one
      if (_isSubtypeOf(newFunc.returnType, oldFunc.returnType)) {
        reasons.add(
            'MINOR: Function ${oldFunc.name} return type changed from ${oldFunc.returnType} to ${newFunc.returnType}, which is a subtype');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      } else {
        reasons.add(
            'MAJOR: Function ${oldFunc.name} return type changed from ${oldFunc.returnType} to ${newFunc.returnType}, which is not a subtype');
        changeType = ChangeType.major;
      }
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
        if (!oldEnum.isDeprecated && newEnum.isDeprecated) {
          reasons.add('MINOR: Enum ${oldEnum.name} is now deprecated');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        }
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
        if (!oldField.isDeprecated && newField.isDeprecated) {
          reasons.add(
              'MINOR: Field ${oldField.name} in class ${oldClass.name} is now deprecated');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        }
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
        if (oldField.isStatic != newField.isStatic) {
          reasons.add(
              'MAJOR: Field ${oldField.name} in class ${oldClass.name} changed static scope');
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
        if (!oldVariable.isDeprecated && newVariable.isDeprecated) {
          reasons.add('MINOR: Variable ${oldVariable.name} is now deprecated');
          if (changeType == ChangeType.none) {
            changeType = ChangeType.minor;
          }
        }
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
      // Check if the new return type is a subtype of the old one
      if (_isSubtypeOf(newMethod.returnType, oldMethod.returnType)) {
        reasons.add(
            'MINOR: Method ${oldMethod.name} return type changed from ${oldMethod.returnType} to ${newMethod.returnType}, which is a subtype');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      } else {
        reasons.add(
            'MAJOR: Method ${oldMethod.name} return type changed from ${oldMethod.returnType} to ${newMethod.returnType}, which is not a subtype');
        changeType = ChangeType.major;
      }
    }

    if (oldMethod.isStatic != newMethod.isStatic) {
      reasons.add('MAJOR: Method ${oldMethod.name} changed static scope');
      changeType = ChangeType.major;
    }

    if (oldMethod.isGetter != newMethod.isGetter ||
        oldMethod.isSetter != newMethod.isSetter) {
      reasons
          .add('MAJOR: Method ${oldMethod.name} changed kind (getter/setter)');
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

      if (!oldParam.isRequired && newParam.isRequired) {
        reasons.add(
            'MAJOR: Parameter ${oldParam.name} in method ${oldMethod.name} changed from optional to required');
        changeType = ChangeType.major;
      } else if (oldParam.isRequired && !newParam.isRequired) {
        reasons.add(
            'MINOR: Parameter ${oldParam.name} in method ${oldMethod.name} changed from required to optional');
        if (changeType == ChangeType.none) {
          changeType = ChangeType.minor;
        }
      } else if (oldParam.kind != newParam.kind) {
        reasons.add(
            'MAJOR: Parameter ${oldParam.name} in method ${oldMethod.name} changed kind from ${oldParam.kind.name} to ${newParam.kind.name}');
        changeType = ChangeType.major;
      } else if (oldParam.type != newParam.type) {
        reasons.add(
            'MAJOR: Parameter ${oldParam.name} in method ${oldMethod.name} changed type from ${oldParam.type} to ${newParam.type}');
        changeType = ChangeType.major;
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
