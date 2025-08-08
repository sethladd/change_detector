This is a comprehensive analysis of changes to a Dart programming language library that constitute a breaking change.

For the purposes of this list:

*   A **Breaking Change** is defined as a modification that causes existing consumer code, which compiled and passed static analysis against the old version, to fail compilation or static analysis against the new version.
*   The **Public API** includes all declarations (classes, functions, etc.) and members (methods, constructors, etc.) that do not start with an underscore (`_`), and anything exposed via `export`.

### I. Removals, Renames, and Visibility

The most direct breaking changes involve removing or hiding API elements.

1.  **Removing a public declaration or member:** Deleting any public class, mixin, enum, extension, typedef, top-level function, variable, constructor, method, field, getter, or setter.
2.  **Renaming a public declaration or member:** This includes renaming named constructors.
3.  **Making a public item private:** Renaming an item to start with an underscore (`_`).
4.  **Moving a declaration between libraries:** Moving a public declaration from one library file to another, unless the original library continues to `export` it.

### II. Hierarchy and Structure Changes

Changes to the nature of types and their relationships.

1.  **Changing the declaration kind:** Changing a `class` to a `mixin`, `enum`, `typedef`, or vice-versa.
2.  **Making a concrete class `abstract`:** Breaks any code that instantiates the class.
3.  **Changing the inheritance hierarchy:**
    *   Changing the superclass in the `extends` clause.
    *   Removing a type from the `implements` clause.
    *   Removing a mixin from the `with` clause.
4.  **Adding members to implementable types (The Interface Break):** Adding a new member (abstract or concrete) to a class or mixin that clients are allowed to `implement`. This breaks implementers as they fail to satisfy the new contract.
5.  **Adding abstract members:** Adding a new abstract member to a class or mixin that clients are allowed to `extend`.
6.  **Tightening Mixin constraints:** Tightening the `on` clause of a mixin (e.g., changing `on A` to `on B` where B is a subtype of A).

#### Dart 3 Class Modifiers

Adding modifiers introduced in Dart 3 restricts usage outside the library and is therefore breaking:

7.  **Adding `final` or `sealed`:** Prevents extending, implementing, or mixing in.
8.  **Adding `base`:** Prevents implementing.
9.  **Adding `interface`:** Prevents extending.

### III. Member and Constructor Modifications

Changes to the nature of fields, methods, and constructors.

1.  **Changing member kind:** Changing a field to a method, a method to a getter, or vice-versa.
2.  **Changing static/instance:** Changing an instance member to a static member, or vice-versa.
3.  **Restricting mutability:**
    *   Changing a mutable field (public `var` or a getter/setter pair) to a `final` field or a getter only.
4.  **Removing the implicit default constructor:** If a class had no explicit constructors, adding the first explicit constructor removes the implicit default one.
5.  **Removing `const` from a constructor:** Breaks code that used the constructor in a constant context (e.g., `const MyClass()`).
6.  **Changing generative to factory:** Changing a generative constructor to a factory constructor breaks subclasses that call it via `super()`.
7.  **Changing `const` values:** Changing the value of a public `const` variable. This breaks compilation if the constant is used in compile-time contexts (e.g., switch cases, metadata annotations, or default parameter values).

### IV. Signatures and Type Changes

This is the most complex area. It affects functions, methods, constructors, fields, and variables.

#### A. Parameter Structure

1.  **Adding a required parameter:** (Positional or Named).
2.  **Removing any parameter:** (Positional or Named, Optional or Required).
3.  **Changing optional to required:** (e.g., adding the `required` keyword, or removing a default value for a non-nullable type).
4.  **Reordering positional parameters.**
5.  **Changing parameter kind:** Changing positional to named, or vice versa.
6.  **Renaming a named parameter.**

#### B. Type Variance and Nullability

In Dart, a breaking change occurs if compilation fails for *either* the **Caller** of the API or the **Implementer/Extender** (a client subclassing or implementing the class). Due to the rules of covariance and contravariance, nearly any change to a type in the public API is breaking.

**1. Parameters (Input Position)**

*   **Narrowing the type** (e.g., `num` to `int`; `T?` to `T`):
    *   **BREAKING for Callers:** Code passing the wider type (e.g., `1.5` or `null`) breaks.
*   **Widening the type** (e.g., `int` to `num`; `T` to `T?`):
    *   **BREAKING for Implementers:** An existing override using the narrower type is no longer a valid override for the wider requirement (violates contravariance rules for overrides).

**2. Return Types, Getters, Final Fields (Output Position)**

*   **Narrowing the type** (e.g., `num` to `int`; `T?` to `T`):
    *   **BREAKING for Implementers:** An existing override returning the wider type is no longer a valid override for the narrower requirement (violates covariance rules for overrides).
*   **Widening the type** (e.g., `int` to `num`; `T` to `T?`):
    *   **BREAKING for Callers:** Code relying on the narrower type (e.g., assigning the result to an `int` variable or assuming non-nullability) breaks.

**3. Mutable Fields**

*   Mutable fields (non-final) have both an implicit getter (Output) and an implicit setter (Input). Since the rules for widening and narrowing conflict between inputs and outputs, changing the type of a public mutable field in *any* way (widening, narrowing, or incompatible) is a breaking change.

**4. Other Type Modifications**

*   **Removing `covariant`:** Removing the `covariant` keyword from a parameter may invalidate existing overrides that relied on it.

### V. Generics

Modifications to the generic type parameters of classes, mixins, methods, or typedefs.

1.  **Adding or removing a type parameter:** (e.g., changing `class Box` to `class Box<T>`).
2.  **Reordering type parameters:** (e.g., changing `<K, V>` to `<V, K>`).
3.  **Tightening Generic Bounds:** Making the constraints stricter (e.g., changing `<T>` to `<T extends num>`).
4.  **Changing the default value of a type parameter:** If the default type inferred by clients changes incompatibly.

### VI. Exports and Infrastructure

1.  **Removing an `export` directive:** Breaks consumers who relied on the transitive access.
2.  **Restricting an `export`:** Adding `show` or `hide` clauses, or removing items from a `show` clause, which hides previously available declarations.
3.  **Adding restrictive annotations:** Adding annotations like `@mustCallSuper` or `@useResult` causes new analysis errors/warnings on existing consumer code.
4.  **Increasing the Minimum SDK Constraint:** Raising the minimum Dart or Flutter SDK version in `pubspec.yaml` can cause package resolution to fail for clients.

### VII. Exhaustiveness (Analyzer Breaks)

These changes often manifest as static analysis errors regarding non-exhaustive switches, which are frequently treated as compilation errors in CI/CD environments.

1.  **Adding a new value to an `enum`.**
2.  **Adding a new subtype to a `sealed` class.**
