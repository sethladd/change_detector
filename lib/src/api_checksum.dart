import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:collection/collection.dart';

class Api {
  final List<ClassApi> classes;
  final List<FunctionApi> functions;
  final List<VariableApi> variables;
  final List<EnumApi> enums;
  final List<MixinApi> mixins;
  final List<ExtensionApi> extensions;

  Api({
    required this.classes,
    required this.functions,
    required this.variables,
    required this.enums,
    required this.mixins,
    required this.extensions,
  });

  factory Api.fromJson(Map<String, dynamic> json) {
    return Api(
      classes:
          (json['classes'] as List).map((c) => ClassApi.fromJson(c)).toList(),
      functions: (json['functions'] as List)
          .map((f) => FunctionApi.fromJson(f))
          .toList(),
      variables: (json['variables'] as List)
          .map((v) => VariableApi.fromJson(v))
          .toList(),
      enums: (json['enums'] as List).map((e) => EnumApi.fromJson(e)).toList(),
      mixins: (json['mixins'] as List? ?? [])
          .map((m) => MixinApi.fromJson(m))
          .toList(),
      extensions: (json['extensions'] as List? ?? [])
          .map((e) => ExtensionApi.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classes': classes.map((c) => c.toJson()).toList(),
      'functions': functions.map((f) => f.toJson()).toList(),
      'variables': variables.map((v) => v.toJson()).toList(),
      'enums': enums.map((e) => e.toJson()).toList(),
      'mixins': mixins.map((m) => m.toJson()).toList(),
      'extensions': extensions.map((e) => e.toJson()).toList(),
    };
  }
}

class ClassApi {
  final String name;
  final List<MethodApi> methods;
  final List<FieldApi> fields;
  final List<ConstructorApi> constructors;
  final String? superclass;
  final List<String> interfaces;
  final List<String> mixins;
  final bool isAbstract;
  final List<TypeParameterApi> typeParameters;
  final bool isDeprecated;

  ClassApi({
    required this.name,
    required this.methods,
    required this.fields,
    required this.constructors,
    this.superclass,
    required this.interfaces,
    required this.mixins,
    required this.isAbstract,
    required this.typeParameters,
    required this.isDeprecated,
  });

  factory ClassApi.fromJson(Map<String, dynamic> json) {
    return ClassApi(
      name: json['name'],
      methods:
          (json['methods'] as List).map((m) => MethodApi.fromJson(m)).toList(),
      fields:
          (json['fields'] as List).map((f) => FieldApi.fromJson(f)).toList(),
      constructors: (json['constructors'] as List? ?? [])
          .map((c) => ConstructorApi.fromJson(c))
          .toList(),
      superclass: json['superclass'],
      interfaces: (json['interfaces'] as List).cast<String>(),
      mixins: (json['mixins'] as List).cast<String>(),
      isAbstract: json['isAbstract'] ?? false,
      typeParameters: (json['typeParameters'] as List? ?? [])
          .map((p) => TypeParameterApi(
                name: p.name.lexeme,
                bound: p.bound?.toString(),
              ))
          .toList(),
      isDeprecated: json['isDeprecated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'methods': methods.map((m) => m.toJson()).toList(),
      'fields': fields.map((f) => f.toJson()).toList(),
      'constructors': constructors.map((c) => c.toJson()).toList(),
      'superclass': superclass,
      'interfaces': interfaces,
      'mixins': mixins,
      'isAbstract': isAbstract,
      'typeParameters': typeParameters.map((p) => p.toJson()).toList(),
      'isDeprecated': isDeprecated,
    };
  }
}

class MethodApi {
  final String name;
  final String returnType;
  final List<ParameterApi> parameters;
  final bool isStatic;
  final bool isDeprecated;
  final bool isGetter;
  final bool isSetter;

  MethodApi({
    required this.name,
    required this.returnType,
    required this.parameters,
    required this.isStatic,
    required this.isDeprecated,
    required this.isGetter,
    required this.isSetter,
  });

  factory MethodApi.fromJson(Map<String, dynamic> json) {
    return MethodApi(
      name: json['name'],
      returnType: json['returnType'],
      parameters: (json['parameters'] as List)
          .map((p) => ParameterApi.fromJson(p))
          .toList(),
      isStatic: json['isStatic'] ?? false,
      isDeprecated: json['isDeprecated'] ?? false,
      isGetter: json['isGetter'] ?? false,
      isSetter: json['isSetter'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'returnType': returnType,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'isStatic': isStatic,
      'isDeprecated': isDeprecated,
      'isGetter': isGetter,
      'isSetter': isSetter,
    };
  }
}

enum ParameterKind {
  positional,
  named,
}

class ParameterApi {
  final String name;
  final String type;
  final ParameterKind kind;
  final bool isRequired;

  ParameterApi({
    required this.name,
    required this.type,
    required this.kind,
    required this.isRequired,
  });

  factory ParameterApi.fromJson(Map<String, dynamic> json) {
    return ParameterApi(
      name: json['name'],
      type: json['type'],
      kind: ParameterKind.values.byName(json['kind']),
      isRequired: json['isRequired'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'kind': kind.name,
      'isRequired': isRequired,
    };
  }
}

class FunctionApi {
  final String name;
  final String returnType;
  final List<ParameterApi> parameters;
  final List<TypeParameterApi> typeParameters;
  final bool isDeprecated;

  FunctionApi({
    required this.name,
    required this.returnType,
    required this.parameters,
    required this.typeParameters,
    required this.isDeprecated,
  });

  factory FunctionApi.fromJson(Map<String, dynamic> json) {
    return FunctionApi(
      name: json['name'],
      returnType: json['returnType'],
      parameters: (json['parameters'] as List)
          .map((p) => ParameterApi.fromJson(p))
          .toList(),
      typeParameters: (json['typeParameters'] as List? ?? [])
          .map((p) => TypeParameterApi(
                name: p.name.lexeme,
                bound: p.bound?.toString(),
              ))
          .toList(),
      isDeprecated: json['isDeprecated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'returnType': returnType,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'typeParameters': typeParameters.map((p) => p.toJson()).toList(),
      'isDeprecated': isDeprecated,
    };
  }
}

class VariableApi {
  final String name;
  final String type;
  final bool isFinal;
  final bool isConst;
  final String? constValue;
  final bool isDeprecated;

  VariableApi({
    required this.name,
    required this.type,
    required this.isFinal,
    required this.isConst,
    this.constValue,
    required this.isDeprecated,
  });

  factory VariableApi.fromJson(Map<String, dynamic> json) {
    return VariableApi(
      name: json['name'],
      type: json['type'],
      isFinal: json['isFinal'],
      isConst: json['isConst'],
      constValue: json['constValue'],
      isDeprecated: json['isDeprecated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'isFinal': isFinal,
      'isConst': isConst,
      'constValue': constValue,
      'isDeprecated': isDeprecated,
    };
  }
}

class FieldApi {
  final String name;
  final String type;
  final bool isFinal;
  final bool isConst;
  final String? constValue;
  final bool isStatic;
  final bool isDeprecated;

  FieldApi({
    required this.name,
    required this.type,
    required this.isFinal,
    required this.isConst,
    this.constValue,
    required this.isStatic,
    required this.isDeprecated,
  });

  factory FieldApi.fromJson(Map<String, dynamic> json) {
    return FieldApi(
      name: json['name'],
      type: json['type'],
      isFinal: json['isFinal'],
      isConst: json['isConst'],
      constValue: json['constValue'],
      isStatic: json['isStatic'] ?? false,
      isDeprecated: json['isDeprecated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'isFinal': isFinal,
      'isConst': isConst,
      'constValue': constValue,
      'isStatic': isStatic,
      'isDeprecated': isDeprecated,
    };
  }
}

class ConstructorApi {
  final String name;
  final List<ParameterApi> parameters;
  final bool isDeprecated;

  ConstructorApi(
      {required this.name,
      required this.parameters,
      required this.isDeprecated});

  factory ConstructorApi.fromJson(Map<String, dynamic> json) {
    return ConstructorApi(
      name: json['name'],
      parameters: (json['parameters'] as List)
          .map((p) => ParameterApi.fromJson(p))
          .toList(),
      isDeprecated: json['isDeprecated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'isDeprecated': isDeprecated,
    };
  }
}

class TypeParameterApi {
  final String name;
  final String? bound;

  TypeParameterApi({required this.name, this.bound});

  factory TypeParameterApi.fromJson(Map<String, dynamic> json) {
    return TypeParameterApi(
      name: json['name'],
      bound: json['bound'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bound': bound,
    };
  }
}

class EnumApi {
  final String name;
  final List<String> values;
  final bool isDeprecated;

  EnumApi(
      {required this.name, required this.values, required this.isDeprecated});

  factory EnumApi.fromJson(Map<String, dynamic> json) {
    return EnumApi(
      name: json['name'],
      values: (json['values'] as List).cast<String>(),
      isDeprecated: json['isDeprecated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'values': values,
      'isDeprecated': isDeprecated,
    };
  }
}

class MixinApi {
  final String name;
  final bool isDeprecated;

  MixinApi({required this.name, required this.isDeprecated});

  factory MixinApi.fromJson(Map<String, dynamic> json) {
    return MixinApi(
      name: json['name'],
      isDeprecated: json['isDeprecated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isDeprecated': isDeprecated,
    };
  }
}

class ExtensionApi {
  final String name;
  final bool isDeprecated;

  ExtensionApi({required this.name, required this.isDeprecated});

  factory ExtensionApi.fromJson(Map<String, dynamic> json) {
    return ExtensionApi(
      name: json['name'],
      isDeprecated: json['isDeprecated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isDeprecated': isDeprecated,
    };
  }
}

class ApiGenerator {
  Api? generateApi(CompilationUnit unit) {
    final visitor = _ApiVisitor();
    unit.accept(visitor);
    return visitor.api;
  }
}

class _ApiVisitor extends GeneralizingAstVisitor<void> {
  final List<ClassApi> _classes = [];
  final List<FunctionApi> _functions = [];
  final List<VariableApi> _variables = [];
  final List<EnumApi> _enums = [];
  final List<MixinApi> _mixins = [];
  final List<ExtensionApi> _extensions = [];
  Api? api;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    super.visitCompilationUnit(node);
    api = Api(
      classes: _classes,
      functions: _functions,
      variables: _variables,
      enums: _enums,
      mixins: _mixins,
      extensions: _extensions,
    );
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.name.lexeme.startsWith('_')) {
      final memberVisitor = _MemberVisitor();
      node.visitChildren(memberVisitor);
      _classes.add(ClassApi(
        name: node.name.lexeme,
        methods: memberVisitor.methods,
        fields: memberVisitor.fields,
        constructors: memberVisitor.constructors,
        superclass: node.extendsClause?.superclass.toString(),
        interfaces: node.implementsClause?.interfaces
                .map((t) => t.toString())
                .toList() ??
            [],
        mixins:
            node.withClause?.mixinTypes.map((t) => t.toString()).toList() ?? [],
        isAbstract: node.abstractKeyword != null,
        typeParameters: node.typeParameters?.typeParameters
                .map((p) => TypeParameterApi(
                      name: p.name.lexeme,
                      bound: p.bound?.toString(),
                    ))
                .toList() ??
            [],
        isDeprecated: node.metadata.any((m) => m.name.name == 'deprecated'),
      ));
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (!node.name.lexeme.startsWith('_')) {
      final parameters =
          node.functionExpression.parameters?.parameters.map((p) {
        final kind = p.isNamed ? ParameterKind.named : ParameterKind.positional;
        final name = p.name?.lexeme ?? '';
        final typeNode = p is DefaultFormalParameter
            ? p.parameter.childEntities
                .firstWhereOrNull((e) => e is TypeAnnotation)
            : p.childEntities.firstWhereOrNull((e) => e is TypeAnnotation);
        final type =
            (typeNode as TypeAnnotation?)?.type?.toString() ?? 'dynamic';
        return ParameterApi(
            name: name, type: type, kind: kind, isRequired: p.isRequired);
      }).toList();

      _functions.add(FunctionApi(
        name: node.name.lexeme,
        returnType: node.returnType?.toString() ?? 'dynamic',
        parameters: parameters ?? [],
        typeParameters: node.functionExpression.typeParameters?.typeParameters
                .map((p) => TypeParameterApi(
                      name: p.name.lexeme,
                      bound: p.bound?.toString(),
                    ))
                .toList() ??
            [],
        isDeprecated: node.metadata.any((m) => m.name.name == 'deprecated'),
      ));
    }
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      if (!variable.name.lexeme.startsWith('_')) {
        String? constValue;
        if (node.variables.isConst && variable.initializer is Literal) {
          constValue = variable.initializer!.toSource();
        }
        _variables.add(VariableApi(
          name: variable.name.lexeme,
          type: node.variables.type?.toString() ?? 'dynamic',
          isFinal: node.variables.isFinal,
          isConst: node.variables.isConst,
          constValue: constValue,
          isDeprecated:
              node.variables.metadata.any((m) => m.name.name == 'deprecated'),
        ));
      }
    }
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    if (!node.name.lexeme.startsWith('_')) {
      _enums.add(EnumApi(
        name: node.name.lexeme,
        values: node.constants.map((c) => c.name.lexeme).toList(),
        isDeprecated: node.metadata.any((m) => m.name.name == 'deprecated'),
      ));
    }
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    if (!node.name.lexeme.startsWith('_')) {
      _mixins.add(MixinApi(
        name: node.name.lexeme,
        isDeprecated: node.metadata.any((m) => m.name.name == 'deprecated'),
      ));
    }
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    if (node.name != null && !node.name!.lexeme.startsWith('_')) {
      _extensions.add(ExtensionApi(
        name: node.name!.lexeme,
        isDeprecated: node.metadata.any((m) => m.name.name == 'deprecated'),
      ));
    }
  }
}

class _MemberVisitor extends GeneralizingAstVisitor<void> {
  final List<MethodApi> methods = [];
  final List<FieldApi> fields = [];
  final List<ConstructorApi> constructors = [];

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (!node.name.lexeme.startsWith('_')) {
      final parameters = node.parameters?.parameters.map((p) {
        final kind = p.isNamed ? ParameterKind.named : ParameterKind.positional;
        final name = p.name?.lexeme ?? '';
        final typeNode = p is DefaultFormalParameter
            ? p.parameter.childEntities
                .firstWhereOrNull((e) => e is TypeAnnotation)
            : p.childEntities.firstWhereOrNull((e) => e is TypeAnnotation);
        final type =
            (typeNode as TypeAnnotation?)?.type?.toString() ?? 'dynamic';
        return ParameterApi(
            name: name, type: type, kind: kind, isRequired: p.isRequired);
      }).toList();

      methods.add(MethodApi(
        name: node.name.lexeme,
        returnType: node.returnType?.toString() ?? 'dynamic',
        parameters: parameters ?? [],
        isStatic: node.isStatic,
        isDeprecated: node.metadata.any((m) => m.name.name == 'deprecated'),
        isGetter: node.isGetter,
        isSetter: node.isSetter,
      ));
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (final variable in node.fields.variables) {
      if (!variable.name.lexeme.startsWith('_')) {
        String? constValue;
        if (node.fields.isConst && variable.initializer is Literal) {
          constValue = variable.initializer!.toSource();
        }
        fields.add(FieldApi(
          name: variable.name.lexeme,
          type: node.fields.type?.toString() ?? 'dynamic',
          isFinal: node.fields.isFinal,
          isConst: node.fields.isConst,
          constValue: constValue,
          isStatic: node.isStatic,
          isDeprecated: node.metadata.any((m) => m.name.name == 'deprecated'),
        ));
      }
    }
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    final parameters = node.parameters.parameters.map((p) {
      final kind = p.isNamed ? ParameterKind.named : ParameterKind.positional;
      final name = p.name?.lexeme ?? '';
      final typeNode = p is DefaultFormalParameter
          ? p.parameter.childEntities
              .firstWhereOrNull((e) => e is TypeAnnotation)
          : p.childEntities.firstWhereOrNull((e) => e is TypeAnnotation);
      final type = (typeNode as TypeAnnotation?)?.type?.toString() ?? 'dynamic';
      return ParameterApi(
          name: name, type: type, kind: kind, isRequired: p.isRequired);
    }).toList();

    constructors.add(ConstructorApi(
      name: node.name?.lexeme ?? '',
      parameters: parameters,
      isDeprecated: node.metadata.any((m) => m.name.name == 'deprecated'),
    ));
  }
}
