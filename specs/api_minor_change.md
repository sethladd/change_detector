Based on the "Dart Programming Language Specification, 6th edition draft," and the principles of Semantic Versioning (SemVer), a MINOR version bump is appropriate for a Dart library when new, backward-compatible functionality is added to the public API. These changes add features without breaking existing consumer code.

The following is a summary of conditions that represent backward-compatible additions to a library's public API surface, thus requiring a Minor version increase:

### Adding New Public Declarations
Introducing entirely new, exported components to a library is the most common reason for a Minor version bump. This includes:
*   Adding a new public class, mixin, extension, enum, or type alias (`typedef`).
*   Adding a new public top-level function.
*   Adding a new public top-level variable (`var`, `final`).

### Adding to Existing Public Declarations
Adding new functionality to existing public types is a Minor change, provided it is done in a backward-compatible way.
*   **Adding New Concrete Members:**
    *   Adding a new public concrete instance method, getter, setter, or field to an existing public class or mixin. **Note:** This can be a breaking change for consumers who `implement` the class's interface rather than `extend` it, as their implementation will become incomplete. [10.1] Therefore, this should only be considered a Minor change for classes that are not intended to be implemented by consumers (e.g., abstract classes with a base class).
    *   Adding a new public `static` method, getter, setter, or field to a class, mixin, or extension.
    *   Adding a new public instance or static method, getter, or setter to an extension.
*   **Adding New Constructors:** Adding a new public constructor to a class (e.g., a new named constructor or a factory constructor) is a non-breaking addition of functionality. [10.7]
*   **Adding New Enum Values:** Adding a new value to an existing public `enum`. While this may cause `switch` statements in consumer code to become non-exhaustive, this results in a static warning, not a compile-time error, and is considered backward-compatible. [18.9]

### Modifying Existing Signatures (Backward-Compatible)
Certain modifications can be made to existing function, method, or constructor signatures that expand their capabilities without breaking existing calls.
*   **Adding Optional Parameters:** Adding a new optional parameter (either positional or named) to a public function or method. Existing calls will continue to work, using the parameter's default value. [9.2.2]
*   **Changing a Required Parameter to Optional:** An existing required parameter can be made optional, as all existing call sites will already be providing a value for it.
*   **Loosening Generic Type Constraints:** The bound on a type parameter can be made less restrictive. For example, changing `class MyClass<T extends num> {}` to `class MyClass<T> {}` is a non-breaking change because all existing valid type arguments will still be valid.
*   **Changing a Return Type to a Subtype:** Changing the return type of a public function or getter to a subtype of the original is a safe, covariant change from the caller's perspective. For instance, changing a return type from `num` to `int` is backward-compatible.

### Deprecating Public API
*   Marking any part of the public API as deprecated (e.g., using the `@deprecated` annotation). This does not break existing code but signals to consumers that the feature will be removed in a future MAJOR version release. The specification covers this under the general concept of "metadata".
