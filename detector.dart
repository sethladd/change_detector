import 'dart:convert';
import 'dart:io';
import 'dart:collection';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

const String MODE_GENERATE = 'generate';
const String MODE_VERIFY = 'verify';
const String OPT_PROJECT = 'project';
const String OPT_LIBRARY = 'library';
const String OPT_CHECKSUM = 'checksum';
const String OPT_MODE = 'mode';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      OPT_MODE,
      allowed: [MODE_GENERATE, MODE_VERIFY],
      mandatory: true,
      help: 'Operation mode.',
    )
    ..addOption(
      OPT_PROJECT,
      mandatory: true,
      help:
          'Path to the root directory of the Dart project (where pubspec.yaml is).',
    )
    ..addOption(
      OPT_LIBRARY,
      mandatory: true,
      help:
          'Path to the entrypoint Dart library file (e.g., lib/main.dart), relative to the project root.',
    )
    ..addOption(
      OPT_CHECKSUM,
      mandatory: true,
      help: 'Path to the checksum JSON file.',
    );

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    stderr.writeln('Error parsing arguments: $e\n');
    stderr.writeln(parser.usage);
    exit(1);
  }

  final mode = argResults[OPT_MODE] as String;
  final projectPath = p.normalize(
    p.absolute(argResults[OPT_PROJECT] as String),
  );
  final libraryRelativePath = argResults[OPT_LIBRARY] as String;
  final libraryPath = p.normalize(p.join(projectPath, libraryRelativePath));
  final checksumPath = p.normalize(
    p.absolute(argResults[OPT_CHECKSUM] as String),
  );

  if (!Directory(projectPath).existsSync()) {
    stderr.writeln('Error: Project directory not found at $projectPath');
    exit(1);
  }
  if (!File(libraryPath).existsSync()) {
    stderr.writeln('Error: Library file not found at $libraryPath');
    exit(1);
  }

  final analyzer = ApiAnalyzer(projectPath);
  print('Analyzing API surface of $libraryRelativePath...');
  // The API surface is represented as a deterministic map (SplayTreeMap).
  final currentApi = await analyzer.analyze(libraryPath);
  print('Analysis complete.');

  if (mode == MODE_GENERATE) {
    await generateChecksum(currentApi, checksumPath);
  } else if (mode == MODE_VERIFY) {
    await verifyChecksum(currentApi, checksumPath);
  }
}

// --- Main Operations ---

Future<void> generateChecksum(Map<String, dynamic> api, String path) async {
  final encoder = JsonEncoder.withIndent('  ');
  // The map is already sorted (SplayTreeMap), so the output is deterministic.
  final jsonString = encoder.convert(api);
  await File(path).writeAsString(jsonString);
  print('Successfully generated checksum at $path');
}

Future<void> verifyChecksum(
  Map<String, dynamic> currentApi,
  String path,
) async {
  if (!File(path).existsSync()) {
    stderr.writeln('Error: Checksum file not found at $path');
    exit(1);
  }

  final jsonString = await File(path).readAsString();
  // Decode into standard maps for the verifier.
  final oldApi = jsonDecode(jsonString) as Map<String, dynamic>;

  final verifier = ApiVerifier(oldApi, currentApi);
  final breakingChanges = verifier.findBreakingChanges();

  if (breakingChanges.isEmpty) {
    print(
      'Verification successful. No backward-incompatible changes detected.',
    );
  } else {
    stderr.writeln('\n--- API BREAKING CHANGES DETECTED ---');
    for (final change in breakingChanges) {
      stderr.writeln('- $change');
    }
    stderr.writeln('-------------------------------------');
    exit(1);
  }
}

// --- Analysis Logic (The Checksum Generator) ---

/// Analyzes the project and extracts the public API surface into a structured map.
class ApiAnalyzer {
  final String projectRoot;
  late final AnalysisContextCollection collection;

  ApiAnalyzer(this.projectRoot) {
    // Initialize the analysis context based on the project root.
    collection = AnalysisContextCollection(includedPaths: [projectRoot]);
  }

  Future<Map<String, dynamic>> analyze(String libraryPath) async {
    final context = collection.contextFor(libraryPath);
    final session = context.currentSession;

    final result = await session.getResolvedLibrary(libraryPath);

    if (result is! ResolvedLibraryResult) {
      throw Exception(
        'Could not resolve library element for $libraryPath. Ensure `dart pub get` has been run. Result: $result',
      );
    }

    // Use SplayTreeMap for deterministic ordering of the top-level elements.
    final Map<String, dynamic> apiSurface = SplayTreeMap();

    // Iterate over the public namespace of the library (includes exports).
    final publicElements = result.element.exportNamespace.definedNames2.values;

    for (final element in publicElements) {
      // Skip synthetic elements (like default constructors if unneeded, or synthesized getters/setters)
      if (element.isSynthetic) continue;

      final name = element.name;
      // Extensions can be unnamed, but most top-level elements must have names.
      if (name == null || name.isEmpty) {
        if (element is ExtensionElement) {
          // Handle unnamed extensions uniquely
          apiSurface['unnamed_extension_${element.hashCode}'] =
              _extractExtension(element);
        }
        continue;
      }

      if (element is InterfaceElement) {
        // Handles Classes, Mixins, and Enums
        apiSurface[name] = _extractInterfaceElement(element);
      } else if (element is FunctionTypedElement) {
        apiSurface[name] =
            _extractExecutable(element as ExecutableElement, 'function');
      } else if (element is TopLevelVariableElement) {
        apiSurface[name] = _extractVariable(element);
      } else if (element is TypeAliasElement) {
        apiSurface[name] = _extractTypedef(element);
      } else if (element is ExtensionElement) {
        apiSurface[name] = _extractExtension(element);
      }
    }

    return apiSurface;
  }

  // --- Extraction Helpers ---

  // Helper to get the display string of a type, ensuring nullability is captured.
  String _typeString(DartType type) {
    return type.getDisplayString(withNullability: true);
  }

  Map<String, dynamic> _extractInterfaceElement(InterfaceElement element) {
    String kind;
    if (element is ClassElement)
      kind = 'class';
    else if (element is MixinElement)
      kind = 'mixin';
    else if (element is EnumElement)
      kind = 'enum';
    else
      kind = 'interface';

    final data = SplayTreeMap<String, dynamic>();
    data['kind'] = kind;

    if (element is ClassElement) {
      data['modifiers'] = _extractModifiers(element);
    }

    if (element is MixinElement && element.isBase) {
      data['modifiers'] = ['base'];
    }

    data['typeParameters'] = _extractTypeParameters(element.typeParameters);

    // Hierarchy
    if (element is ClassElement || element is EnumElement) {
      data['supertype'] =
          element.supertype != null && !element.supertype!.isDartCoreObject
              ? _typeString(element.supertype!)
              : null;
    }
    if (element is MixinElement) {
      data['on'] = element.superclassConstraints.map(_typeString).toList()
        ..sort();
    }
    data['interfaces'] = element.interfaces.map(_typeString).toList()..sort();
    data['mixins'] = element.mixins.map(_typeString).toList()..sort();

    // Members
    data['members'] = _extractMembers(element);

    // Enum Values
    if (element is EnumElement) {
      // Enum value order matters for enhanced enums.
      data['enumValues'] = element.fields
          .where((f) => f.isEnumConstant && f.isPublic)
          .map((f) => f.name)
          .toList();
    }

    return data;
  }

  Map<String, dynamic> _extractExtension(ExtensionElement element) {
    final data = SplayTreeMap<String, dynamic>();
    data['kind'] = 'extension';
    data['on'] = _typeString(element.extendedType);
    data['typeParameters'] = _extractTypeParameters(element.typeParameters);
    data['members'] = _extractMembers(element);
    return data;
  }

  Map<String, dynamic> _extractMembers(Element element) {
    final members = SplayTreeMap<String, dynamic>();

    List<ExecutableElement> executables = [];
    List<FieldElement> fields = [];

    if (element is InterfaceElement) {
      executables.addAll(element.methods);
      executables.addAll(element.fields
          .where((f) => f.isSynthetic && f.getter != null)
          .map((f) => f.getter!));
      executables.addAll(element.fields
          .where((f) => f.isSynthetic && f.setter != null)
          .map((f) => f.setter!));
      fields.addAll(element.fields);
      if (element is ClassElement || element is EnumElement) {
        executables.addAll(element.constructors);
      }
    } else if (element is ExtensionElement) {
      executables.addAll(element.methods);
      executables.addAll(element.fields
          .where((f) => f.isSynthetic && f.getter != null)
          .map((f) => f.getter!));
      executables.addAll(element.fields
          .where((f) => f.isSynthetic && f.setter != null)
          .map((f) => f.setter!));
    }

    for (final exec in executables) {
      if (exec.isPublic) {
        // Skip synthetic accessors if the corresponding field is public.
        if (exec.isSynthetic &&
            exec is PropertyAccessorElement &&
            exec.variable.isPublic) {
          continue;
        }

        String kind;
        String? name = exec.name;
        if (name == null) continue;

        if (exec is ConstructorElement) {
          kind = 'constructor';
          // Skip synthetic default constructor
          if (exec.isSynthetic && name.isEmpty) continue;
          name = name.isEmpty ? 'new' : name;
        } else if (exec is PropertyAccessorElement) {
          kind = exec.kind == ElementKind.GETTER ? 'getter' : 'setter';
          name = exec
              .displayName; // Use display name which removes the '=' for setters
        } else {
          kind = 'method';
        }

        // Use a unique key to distinguish getters/setters/methods/constructors
        final key = '$kind:$name';
        members[key] = _extractExecutable(exec, kind);
      }
    }

    for (final field in fields) {
      // Enum constants are handled separately. We also skip synthetic fields.
      if (field.isPublic && !field.isSynthetic && !field.isEnumConstant) {
        final key = 'field:${field.name}';
        members[key] = _extractVariable(field);
      }
    }

    return members;
  }

  Map<String, dynamic> _extractExecutable(
    ExecutableElement element,
    String kind,
  ) {
    final data = SplayTreeMap<String, dynamic>();
    data['kind'] = kind;
    data['static'] = element.isStatic;
    data['abstract'] = element.isAbstract;

    if (element is ConstructorElement) {
      data['const'] = element.isConst;
      data['factory'] = element.isFactory;
    }

    data['returnType'] = _typeString(element.returnType);
    data['typeParameters'] = _extractTypeParameters(element.typeParameters);
    data['parameters'] =
        element.formalParameters.map(_extractParameter).toList();
    return data;
  }

  Map<String, dynamic> _extractParameter(dynamic element) {
    String kind;
    if (element.isRequiredPositional)
      kind = 'RP'; // Required Positional
    else if (element.isOptionalPositional)
      kind = 'OP'; // Optional Positional
    else if (element.isRequiredNamed)
      kind = 'RN'; // Required Named
    else if (element.isOptionalNamed)
      kind = 'ON'; // Optional Named
    else
      kind = 'UNKNOWN';

    return {
      'name': element.name,
      'type': _typeString(element.type),
      'kind': kind,
      'hasDefault': element.hasDefaultValue,
    };
  }

  Map<String, dynamic> _extractVariable(VariableElement element) {
    final data = SplayTreeMap<String, dynamic>();
    data['kind'] = element is FieldElement ? 'field' : 'variable';
    data['type'] = _typeString(element.type);
    data['static'] = element.isStatic;
    data['final'] = element.isFinal;
    data['const'] = element.isConst;
    return data;
  }

  Map<String, dynamic> _extractTypedef(TypeAliasElement element) {
    final data = SplayTreeMap<String, dynamic>();
    data['kind'] = 'typedef';
    data['aliasedType'] = _typeString(element.aliasedType);
    data['typeParameters'] = _extractTypeParameters(element.typeParameters);
    return data;
  }

  List<String> _extractTypeParameters(List<TypeParameterElement> params) {
    // Order matters
    return params.map((p) {
      var s = p.name;
      if (p.bound != null) {
        s = '$s extends ${_typeString(p.bound!)}';
      }
      return s ?? '';
    }).toList();
  }

  List<String> _extractModifiers(ClassElement element) {
    final modifiers = <String>[];
    if (element.isAbstract) modifiers.add('abstract');
    if (element.isBase) modifiers.add('base');
    if (element.isFinal) modifiers.add('final');
    if (element.isInterface) modifiers.add('interface');
    if (element.isSealed) modifiers.add('sealed');
    if (element.isMixinClass) modifiers.add('mixin_class');
    return modifiers..sort();
  }
}

// --- Verification Logic (The Compatibility Checker) ---

/// Compares the old API structure with the new API structure to find breaking changes.
class ApiVerifier {
  final Map<String, dynamic> oldApi;
  final Map<String, dynamic> newApi;
  final List<String> breakingChanges = [];

  ApiVerifier(this.oldApi, this.newApi);

  List<String> findBreakingChanges() {
    // Rule: Everything in the old API must exist in the new API in a compatible way.
    // Additions in the new API are ignored.

    for (final elementName in oldApi.keys) {
      if (!newApi.containsKey(elementName)) {
        _reportBreak(elementName, 'Public declaration removed.');
      } else {
        _compareDeclarations(
          elementName,
          oldApi[elementName],
          newApi[elementName],
        );
      }
    }

    return breakingChanges;
  }

  void _reportBreak(String context, String reason) {
    breakingChanges.add('$context: $reason');
  }

  void _compareDeclarations(
    String context,
    Map<String, dynamic> oldDecl,
    Map<String, dynamic> newDecl,
  ) {
    if (oldDecl['kind'] != newDecl['kind']) {
      _reportBreak(
        context,
        'Kind changed from ${oldDecl['kind']} to ${newDecl['kind']}.',
      );
      return;
    }

    final kind = oldDecl['kind'];

    switch (kind) {
      case 'class':
      case 'mixin':
      case 'enum':
      case 'interface':
        _compareInterface(context, oldDecl, newDecl);
        break;
      case 'extension':
        _compareExtension(context, oldDecl, newDecl);
        break;
      case 'function':
        _compareExecutables(context, oldDecl, newDecl);
        break;
      case 'variable':
        _compareVariables(context, oldDecl, newDecl);
        break;
      case 'typedef':
        _compareTypedefs(context, oldDecl, newDecl);
        break;
    }
  }

  void _compareInterface(
    String context,
    Map<String, dynamic> oldDecl,
    Map<String, dynamic> newDecl,
  ) {
    // 1. Modifiers (Dart 3)
    final oldMods = Set<String>.from(oldDecl['modifiers'] ?? []);
    final newMods = Set<String>.from(newDecl['modifiers'] ?? []);
    // Breaking if new restrictions are added (e.g., class -> final class)
    final addedRestrictions = newMods.difference(oldMods);
    if (addedRestrictions.isNotEmpty) {
      // This is a simplified check. A more nuanced check would look at combinations (e.g., adding 'base' restricts implementation unless 'final' or 'sealed' is also present).
      _reportBreak(context, 'Added restrictive modifiers: $addedRestrictions.');
    }

    // Changing concrete to abstract
    if (!oldMods.contains('abstract') && newMods.contains('abstract')) {
      _reportBreak(context, 'Changed from concrete to abstract.');
    }

    // 2. Hierarchy
    if (oldDecl['supertype'] != newDecl['supertype']) {
      // Changing the supertype is generally breaking.
      _reportBreak(
        context,
        'Supertype changed from ${oldDecl['supertype']} to ${newDecl['supertype']}.',
      );
    }

    // Check 'implements' and 'with'. Breaking if interfaces/mixins are removed.
    _checkRemovedTypes(context, 'interfaces', oldDecl, newDecl);
    _checkRemovedTypes(context, 'mixins', oldDecl, newDecl);

    // Check 'on' constraints for mixins. Adding constraints is breaking.
    if (oldDecl['kind'] == 'mixin') {
      final oldOn = Set<String>.from(oldDecl['on'] ?? []);
      final newOn = Set<String>.from(newDecl['on'] ?? []);
      if (!oldOn.containsAll(newOn) || !newOn.containsAll(oldOn)) {
        // Conservatively assume any change to 'on' constraints is breaking.
        _reportBreak(context, 'Mixin "on" constraints changed.');
      }
    }

    // 3. Generics (Type parameters and bounds)
    if ((oldDecl['typeParameters'] ?? []).toString() !=
        (newDecl['typeParameters'] ?? []).toString()) {
      _reportBreak(context, 'Generic parameters or bounds changed.');
    }

    // 4. Members
    _compareMembers(
      context,
      oldDecl['members'] ?? {},
      newDecl['members'] ?? {},
    );

    // 5. Enum Values
    if (oldDecl.containsKey('enumValues')) {
      final oldValues = List<String>.from(oldDecl['enumValues']);
      final newValues = List<String>.from(newDecl['enumValues']);

      // Check for removals
      final removedValues = oldValues.toSet().difference(newValues.toSet());
      if (removedValues.isNotEmpty) {
        _reportBreak(context, 'Removed enum values: $removedValues.');
      }

      // Check for order changes (important for enhanced enums)
      bool orderChanged = false;
      for (int i = 0; i < oldValues.length && i < newValues.length; i++) {
        if (oldValues[i] != newValues[i]) {
          orderChanged = true;
          break;
        }
      }
      if (orderChanged) {
        _reportBreak(context, 'Enum value order changed.');
      }
    }
  }

  void _checkRemovedTypes(
    String context,
    String key,
    Map<String, dynamic> oldDecl,
    Map<String, dynamic> newDecl,
  ) {
    final oldTypes = Set<String>.from(oldDecl[key] ?? []);
    final newTypes = Set<String>.from(newDecl[key] ?? []);
    final removedTypes = oldTypes.difference(newTypes);
    if (removedTypes.isNotEmpty) {
      _reportBreak(context, 'Removed $key: $removedTypes.');
    }
  }

  void _compareExtension(
    String context,
    Map<String, dynamic> oldDecl,
    Map<String, dynamic> newDecl,
  ) {
    if (oldDecl['on'] != newDecl['on']) {
      _reportBreak(
        context,
        'Extension target type ("on" clause) changed from ${oldDecl['on']} to ${newDecl['on']}.',
      );
    }
    _compareMembers(
      context,
      oldDecl['members'] ?? {},
      newDecl['members'] ?? {},
    );
  }

  void _compareMembers(
    String context,
    Map<String, dynamic> oldMembers,
    Map<String, dynamic> newMembers,
  ) {
    for (final memberKey in oldMembers.keys) {
      final memberContext = '$context -> $memberKey';
      if (!newMembers.containsKey(memberKey)) {
        _reportBreak(memberContext, 'Public member removed.');
      } else {
        final oldMember = oldMembers[memberKey];
        final newMember = newMembers[memberKey];

        if (oldMember['kind'] != newMember['kind']) {
          // Should be caught by the key comparison (since kind is in the key), but safe check.
          _reportBreak(memberContext, 'Member kind changed.');
          continue;
        }

        final kind = oldMember['kind'];
        if (kind == 'field' || kind == 'variable') {
          _compareVariables(memberContext, oldMember, newMember);
        } else {
          // methods, constructors, getters, setters
          _compareExecutables(memberContext, oldMember, newMember);
        }
      }
    }
  }

  void _compareVariables(
    String context,
    Map<String, dynamic> oldVar,
    Map<String, dynamic> newVar,
  ) {
    if (oldVar['type'] != newVar['type']) {
      // Changing a variable/field type is almost always breaking.
      _reportBreak(
        context,
        'Type changed from ${oldVar['type']} to ${newVar['type']}.',
      );
    }

    // Changing from mutable to final/const is breaking.
    final bool oldIsMutable =
        oldVar['final'] == false && oldVar['const'] == false;
    final bool newIsMutable =
        newVar['final'] == false && newVar['const'] == false;

    if (oldIsMutable && !newIsMutable) {
      _reportBreak(context, 'Changed from mutable to final/const.');
    }

    // Removing const from a const variable is breaking.
    if (oldVar['const'] == true && newVar['const'] == false) {
      _reportBreak(context, 'Removed "const" modifier.');
    }

    if (oldVar['static'] != newVar['static']) {
      _reportBreak(context, 'Static modifier changed.');
    }
  }

  void _compareTypedefs(
    String context,
    Map<String, dynamic> oldDef,
    Map<String, dynamic> newDef,
  ) {
    // Typedefs are complex. If the definition changes, it's likely breaking.
    if (oldDef['aliasedType'] != newDef['aliasedType']) {
      _reportBreak(context, 'Typedef definition changed.');
    }
    // Also check type parameters/bounds
    if ((oldDef['typeParameters'] ?? []).toString() !=
        (newDef['typeParameters'] ?? []).toString()) {
      _reportBreak(context, 'Typedef generic parameters or bounds changed.');
    }
  }

  void _compareExecutables(
    String context,
    Map<String, dynamic> oldExec,
    Map<String, dynamic> newExec,
  ) {
    // 1. Return Type
    if (oldExec['returnType'] != newExec['returnType']) {
      // We conservatively flag any return type change as breaking.
      // True covariance checking requires deep type system knowledge beyond this script.
      _reportBreak(
        context,
        'Return type changed from ${oldExec['returnType']} to ${newExec['returnType']}.',
      );
    }

    // 2. Static/Instance
    if (oldExec['static'] != newExec['static']) {
      _reportBreak(context, 'Static modifier changed.');
    }

    // 3. Abstract (Adding abstract methods to a non-abstract class is breaking)
    // This is complex as it depends on the class context. We check if an existing method became abstract.
    if (oldExec['abstract'] == false && newExec['abstract'] == true) {
      _reportBreak(context, 'Method changed from concrete to abstract.');
    }

    // 4. Constructor specific checks
    if (oldExec['kind'] == 'constructor') {
      if (oldExec['const'] == true && newExec['const'] == false) {
        _reportBreak(context, 'Removed "const" from constructor.');
      }
      if (oldExec['factory'] != newExec['factory']) {
        _reportBreak(context, 'Factory status changed.');
      }
    }

    // 5. Generics (Type parameters and bounds)
    if ((oldExec['typeParameters'] ?? []).toString() !=
        (newExec['typeParameters'] ?? []).toString()) {
      _reportBreak(context, 'Generic parameters or bounds changed.');
    }

    // 6. Parameters (The most critical part)
    _compareParameters(
      context,
      oldExec['parameters'] ?? [],
      newExec['parameters'] ?? [],
    );
  }

  void _compareParameters(
    String context,
    List<dynamic> oldParamsList,
    List<dynamic> newParamsList,
  ) {
    // Categorize parameters for easier comparison.
    final List<Map<String, dynamic>> oldPositional = [];
    final Map<String, Map<String, dynamic>> oldNamed = {};
    final List<Map<String, dynamic>> newPositional = [];
    final Map<String, Map<String, dynamic>> newNamed = {};

    void categorize(
      List<dynamic> params,
      List<Map<String, dynamic>> posList,
      Map<String, Map<String, dynamic>> namedMap,
    ) {
      for (final param in params) {
        final p = param as Map<String, dynamic>;
        if (p['kind'] == 'RP' || p['kind'] == 'OP') {
          posList.add(p);
        } else if (p['kind'] == 'RN' || p['kind'] == 'ON') {
          namedMap[p['name']] = p;
        }
      }
    }

    categorize(oldParamsList, oldPositional, oldNamed);
    categorize(newParamsList, newPositional, newNamed);

    // --- Positional Parameter Checks ---

    // Rule 1: Cannot add new required positional parameters.
    int oldRequiredPosCount =
        oldPositional.where((p) => p['kind'] == 'RP').length;
    int newRequiredPosCount =
        newPositional.where((p) => p['kind'] == 'RP').length;

    if (newRequiredPosCount > oldRequiredPosCount) {
      _reportBreak(context, 'Added new required positional parameters.');
    }

    // Rule 2: Check existing positional parameters for compatibility.
    for (var i = 0; i < oldPositional.length; i++) {
      final oldP = oldPositional[i];

      if (i >= newPositional.length) {
        // Rule 2a: Cannot remove existing positional parameters (or change them to named).
        _reportBreak(
          context,
          'Removed positional parameter [$i] (${oldP['name']}).',
        );
        break; // Subsequent parameters are also effectively removed/shifted.
      }

      final newP = newPositional[i];

      // Rule 2b: Cannot change the type (Contravariance).
      // We conservatively flag any type change.
      if (oldP['type'] != newP['type']) {
        _reportBreak(
          context,
          'Positional parameter [$i] type changed from ${oldP['type']} to ${newP['type']}.',
        );
      }

      // Rule 2c: Cannot change optional to required.
      if (oldP['kind'] == 'OP' && newP['kind'] == 'RP') {
        _reportBreak(
          context,
          'Positional parameter [$i] changed from optional to required.',
        );
      }
    }

    // --- Named Parameter Checks ---

    // Rule 3: Check existing named parameters for compatibility.
    for (final name in oldNamed.keys) {
      final oldP = oldNamed[name]!;
      final newP = newNamed[name];

      // Rule 3a: Cannot remove existing named parameters.
      if (newP == null) {
        _reportBreak(context, 'Removed named parameter {$name}.');
        continue;
      }

      // Rule 3b: Cannot change the type.
      if (oldP['type'] != newP['type']) {
        _reportBreak(
          context,
          'Named parameter {$name} type changed from ${oldP['type']} to ${newP['type']}.',
        );
      }

      // Rule 3c: Cannot change optional to required.
      if (oldP['kind'] == 'ON' && newP['kind'] == 'RN') {
        _reportBreak(
          context,
          'Named parameter {$name} changed from optional to required.',
        );
      }
    }

    // Rule 4: Cannot add new required named parameters.
    for (final name in newNamed.keys) {
      final newP = newNamed[name]!;
      if (newP['kind'] == 'RN' && !oldNamed.containsKey(name)) {
        _reportBreak(context, 'Added new required named parameter {$name}.');
      }
    }
  }
}
