To build a program that detects ABI-breaking changes in a Dart library, you need a precise definition of what constitutes the Dart ABI.

The Dart ABI (Application Binary Interface) is the low-level contract between compiled components (such as AOT snapshots or Dill/Kernel files). An ABI break occurs when a change in a library invalidates the assumptions made by previously compiled code that depends on it. This can cause linkage errors, runtime errors (like `NoSuchMethodError`), crashes, or memory corruption.

Here is a comprehensive list of changes to a Dart library that are considered ABI-breaking.

### I. Memory Layout Changes (The Silent Breakers)

When Dart code is compiled (especially AOT), instance fields are accessed using fixed memory offsets from the start of the object. If the layout changes, these offsets become invalid, leading to memory corruption or crashes.

**Crucially, these changes break the ABI even if the fields involved are private**, because private fields still occupy space and affect the offsets of subsequent fields.

1.  **Reordering Instance Fields:** Changing the declaration order of instance fields.
    ```dart
    // Old Version
    class Point {
      int x; // e.g., Offset 8
      int y; // e.g., Offset 16
    }

    // New Version (Breaking Change)
    class Point {
      int y; // Now Offset 8
      int x; // Now Offset 16
    }
    // Old compiled code trying to access 'x' will now read the value of 'y'.
    ```
2.  **Removing Instance Fields:** Removing any instance field shifts the offsets of all subsequent fields in the class and all its subclasses.
3.  **Adding New Instance Fields:**
    *   Adding a field anywhere except the very end of the class's declaration list.
    *   Adding a field to a superclass. This fundamentally changes the memory layout of all subclasses.
4.  **Changing the Type of an Instance Field:** If the new type has a different memory representation or size (e.g., changing `int` to `double`, or `Object` to a specialized type), it shifts the layout.

*(Note: Changes to static fields do not affect instance memory layout and are ABI safe.)*

### II. Linkage, Visibility, and Location

Compiled code references entities by specific symbol names and locations. If these change, the linkage fails.

5.  **Removing a Public Declaration:** Deleting a public class, mixin, enum, typedef, extension, top-level function, or variable.
6.  **Renaming a Public Declaration:** Renaming is treated as removing the old symbol and adding a new one.
7.  **Reducing Visibility:** Changing a public declaration to private (adding `_`).
8.  **Moving a Declaration Between Libraries:** The canonical URI of a declaration is part of its identity in Dart. Moving a class from `lib_a.dart` to `lib_b.dart` breaks the linkage.
9.  **Modifying Exports:** Removing an `export` directive or adding `show`/`hide` combinators that conceal previously exported names.

### III. Class Structure and Hierarchy

Changes to the inheritance chain or the fundamental nature of a type alter the memory layout, the structure of method dispatch tables (similar to vtables/itables), and runtime type information.

10. **Changing the Superclass:** Modifying the `extends` clause.
11. **Modifying Mixins:** Adding, removing, or reordering types in the `with` clause. This changes the class linearization and Method Resolution Order (MRO).
12. **Removing Interfaces:** Removing a type from the `implements` clause.
13. **Changing the Kind of Declaration:** Changing a `class` to a `mixin`, `enum`, or vice-versa.
14. **Changing Abstractness:** Changing a concrete class to `abstract`. Existing compiled code that instantiated the class will fail.
15. **Adding Restrictive Class Modifiers (Dart 3+):** Adding `sealed`, `base`, `interface`, or `final` to a previously unrestricted class breaks existing external implementations or subclasses.

### IV. Function Signatures and Calling Conventions

The signature defines how arguments are passed and how the return value is handled. This applies to methods, constructors, top-level functions, getters, and setters.

16. **Changing the Return Type.**
17. **Changing Parameter Types.**
18. **Modifying Positional Parameters:**
    *   Adding a required positional parameter.
    *   Removing any positional parameter (even optional ones).
    *   Reordering positional parameters.
19. **Modifying Named Parameters:**
    *   Renaming a named parameter (the name is part of the Dart selector used for invocation).
    *   Removing a named parameter.
20. **Changing Parameter Kinds:**
    *   Changing positional to named, or vice-versa.
    *   Changing optional to required, or vice-versa.
21. **Nullability Changes:** Changing a parameter or return type from `T` to `T?` or vice-versa.
22. **Adding/Removing `async`, `async*`, or `sync*`:** This changes the return type (e.g., `T` to `Future<T>`) and the execution mechanics.

### V. Member Kinds

The mechanism for accessing a member is part of the ABI.

23. **Static vs. Instance:** Changing an instance member to static, or vice-versa. The calling conventions are entirely different (instance calls require a `this` receiver).
24. **Member Kind:** Changing a field to a getter/setter, or a method to a field, etc. A direct memory access (field) is different from a function invocation (method/getter).
25. **Constructor Kind:** Changing a generative constructor to a factory constructor, or vice-versa.
26. **Const Modifier:** Removing `const` from a constructor. Compiled code may have relied on it in a constant context.

### VI. The Fragile Base Class Problem

In object-oriented languages, adding functionality to a base class can break subclasses compiled against an older version.

27. **Adding Instance Members to Extendable Classes:** If a class is not `final` or `sealed`, adding a new instance method, getter, or setter is an ABI break.
    *   *Why:* A previously compiled subclass outside the library might already declare a member with the same name but an incompatible signature (e.g., different return type). When the VM attempts to load the application, it will detect the invalid override conflict and fail.
28. **Adding an abstract method:** This forces existing concrete subclasses to implement the method, breaking them if they haven't been recompiled.

### VII. Generics

Changes to generics affect how types are specialized and represented at runtime.

29. **Changing Type Parameter Arity:** Adding or removing type parameters (e.g., changing `class Box<T>` to `class Box<T, V>`).
30. **Reordering Type Parameters:** (e.g., changing `class Pair<A, B>` to `class Pair<B, A>`).
31. **Changing Type Parameter Bounds:** Modifying the `extends` clause of a type parameter (e.g., changing `<T extends num>` to `<T extends int>`).

### VIII. Constants and Enums (Behavioral ABI Breaks)

Constants and default values present a unique challenge because they are often **inlined** at the compilation site.

32. **Changing the Value of a Public Constant:** If a `const` value changes, precompiled code will continue to use the *old* value that was inlined. This does not break linkage but leads to inconsistent runtime behavior (a behavioral ABI break).
33. **Changing Default Parameter Values:** Similar to constants, default parameter values are compiled into the call site. Changing the value is a behavioral ABI break.
34. **Enum Modifications:**
    *   Removing or renaming enum values.
    *   Reordering enum values.
    *   Inserting new enum values (except at the very end).
    *   *Why:* The ABI contract includes the integer `index` of the values. Changing the order or inserting values changes the indices.

### IX. FFI (Foreign Function Interface)

If the library uses `dart:ffi`, it is highly sensitive to ABI changes as it must map directly to native memory layouts (C ABI).

35. **FFI Struct/Union Layout:** For classes extending `Struct` or `Union`:
    *   Reordering fields.
    *   Adding or removing fields.
    *   Changing the native type annotations (e.g., `@Int32()` to `@Int64()`).
    *   Changing the size of inline arrays.
36. **Packing/Alignment:** Adding, removing, or changing the `@Packed(N)` annotation.
37. **Native Function Signatures:** Changing the signature defined in `FfiNative` or the `typedef`s used with `DynamicLibrary.lookupFunction`.
