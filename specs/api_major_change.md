Based on the "Dart Programming Language Specification, 6th edition draft," a MAJOR version bump is required for a Dart library when an incompatible, or "breaking," change is made to its public API. The public API consists of all declarations (such as classes, functions, and variables) that are not private (i.e., do not start with an underscore `_`) and are exported by the library. [6.2, 19.2]

The following is a summary of conditions that constitute a breaking change to a library's public API surface, thus requiring a Major version increase:

### Top-Level Declarations
Changes to any public, exported declaration at the library level are breaking if they:
*   **Remove a Declaration:** A public top-level class, mixin, extension, enum, function, type alias, or variable is removed.
*   **Rename a Declaration:** A public top-level declaration is renamed.
*   **Change a Variable's Type:** The type of a public variable is changed to an incompatible type (i.e., a type that is not a supertype of the old type).
*   **Change a Constant's Value:** The value of a public `const`-declared variable is changed.

### Changes to Classes, Mixins, and Extensions
Structural changes to public type declarations are breaking in the following cases:
*   **Adding `abstract`:** A concrete, instantiable public class is made `abstract`, as this prevents consumers from creating instances of it directly.
*   **Changing Supertype Hierarchies:**
    *   The superclass of a public class is changed, and the new superclass does not provide a superset of the original superclass's public instance members. [10.9]
    *   A super-interface is added to a public class (or one of its existing supertypes) that introduces new abstract members. This is a breaking change for consumers who implement the class's interface. [10.10]
*   **Changing a Mixin's Constraints:** A new, more restrictive superclass constraint (an `on` clause) is added to a public mixin, which can prevent it from being applied in existing use cases. [12.2]
*   **Changing an Extension's Target:** The target type (`on` clause) of a public extension is changed to a more restrictive type, causing it to no longer apply to types it previously did.
*   **Changing a Type Alias:** The underlying type of a public `typedef` is changed to a new type that is not a subtype of the original. [20.3]

### Changes to Members of Public Types
Any modification to public members (instance or static) of an exported class, mixin, or extension that breaks client code is a major change. This includes:
*   **Removing or Renaming Members:** A public method, operator, field, getter, or setter is removed or renamed.
*   **Changing Member Scope:** A member is changed from `static` to instance, or vice-versa.
*   **Restricting a Field:** A mutable public field (one with a public setter) is changed to be `final` or `const`, as this effectively removes the setter. [10.6]
*   **Changing a Field's Type:** The type of a public field is changed to an incompatible type. For a field to be compatible, its new type must be a subtype of the old type (for the getter) and a supertype of the old type (for the setter). A direct change to a non-subtype is breaking.

### Changes to Function, Method, and Constructor Signatures
Incompatible changes to the signature of any public function, method, or constructor are breaking changes:
*   **Parameters:**
    *   Adding a new required parameter (either positional or named). [9.2.1]
    *   Changing an existing optional parameter to be required.
    *   Removing any parameter.
    *   Renaming a named parameter.
    *   Changing a parameter's type to a non-supertype. For example, changing a parameter of type `Object` to `String` is a breaking change because consumers could no longer pass a non-`String` object. [11.2.2]
*   **Return Values:** Changing the return type of a function or getter to a type that is not a subtype of the original return type. [11.2.2]
*   **Constructors:**
    *   Removing a public constructor. [10.7]
    *   Changing a generative constructor to a factory constructor, as this prevents subclasses from being able to call `super()`. [10.7.1, 10.7.2]

### Changes to Generic Types
Modifications to the type parameters of a public generic class, mixin, extension, or function are breaking if they include:
*   Adding or removing a type parameter.
*   Making a type parameter's bound more restrictive. For example, changing `<T>` to `<T extends num>` is a breaking change for any consumer that used the type with a non-`num` argument.

### Changes to Enums
Because enums are a fixed set of constants, the following changes to a public enum are breaking:
*   Removing an enum value.
*   Renaming an enum value.
*   Reordering enum values, as this changes the public `index` of each value.
