A Dart-based "wrapper" (shim or polyfill) works by presenting an old API surface while internally using the new implementation. This strategy fails when a change affects fundamental semantics, the type system, or VM-level behaviors that user-level Dart code cannot intercept or emulate. A wrapper must obey the rules of the Dart platform it runs on; it cannot force the platform to behave like an older version.

Here are the categories of changes to Dart core libraries that are impossible to provide backwards compatibility for using a pure Dart-based wrapper.

### I. Changes to the Type System and Language Semantics

If the fundamental rules of the Dart language change, a wrapper cannot force the compiler or runtime to ignore those rules.

#### 1. Sound Null Safety (NNBD)

The introduction of Null Safety in Dart 2.12 is the canonical example. The meaning of types fundamentally changed; `String` became strictly non-nullable, distinct from `String?`.

*   **Why it's impossible to wrap:** The compiler optimizes code based on the guarantee that a non-nullable variable will never be null, and the runtime enforces this. A wrapper cannot disable these runtime checks or convince the static analyzer that `null` is a valid member of the type `String`.

#### 2. Changes to the Core Type Hierarchy (The "is" Check Problem)

The relationships between types are defined by the language specification and enforced by the VM.

*   **Example:** If `List` stopped implementing the `Queue` interface.
*   **Why it's impossible to wrap:** Runtime type checks (`is`, `as`) query the VM directly. A wrapper cannot intercept the `is` operator or alter the VM's internal class tables to make `myList is Queue` return true if the core definition has changed.

#### 3. Introduction of Class Modifiers

Dart 3 introduced modifiers like `final`, `base`, and `sealed`. Applying these to previously open core library classes breaks existing extensions or implementations.

*   **Why it's impossible to wrap:** If a core class `C` is marked `final`, existing user code `class MyC extends C {}` breaks at compile time. A wrapper library cannot "un-finalize" the core definition.

#### 4. Changes to Generics Variance

If the rules regarding how generic types relate to each other (covariance, invariance) are changed.

*   **Why it's impossible to wrap:** Variance rules determine subtype relationships (e.g., that `List<int>` is a subtype of `List<num>`). These are fundamental language rules enforced by the static analyzer, which a wrapper cannot bypass.

### II. Changes to Core Type Representation and Intrinsics

Certain types (`int`, `double`, `String`, `bool`) are "magic." The VM and compilers understand them intrinsically and apply heavy optimizations (intrinsification) that bypass standard Dart method calls.

#### 1. Integer Representation and Precision

The transition from Dart 1 (arbitrary precision integers) to Dart 2 (fixed 64-bit integers on the VM) fundamentally changed overflow behavior.

*   **Why it's impossible to wrap:** Arithmetic operations (`+`, `*`) on `int` are typically compiled directly to native machine instructions. If the result overflows, the precision is lost immediately. A wrapper cannot intercept these fundamental operations to substitute a different implementation.

#### 2. Identity and Equality Semantics

The behavior of `operator ==` for core types and the `identical()` function are foundational.

*   **Why it's impossible to wrap:** Equality checks on primitives are often intrinsified and cannot be overridden globally. Furthermore, `identical()` is a direct query to the VM's memory management regarding object identity and canonicalization, which cannot be altered by Dart code.

### III. Changes to Class Structure and API Surface

While many API changes are wrappable, certain structural changes cannot be hidden due to the limitations of Dart's abstraction mechanisms.

#### 1. Changing Instance Method Signatures

If the signature of an instance method on a core type changes incompatibly (e.g., adding a required parameter).

*   **Why it's impossible to wrap:** Dart resolves instance method calls based on the static type of the receiver. Extension methods *cannot* override existing instance methods. If `myString.contains(...)` is called, the compiler resolves it to the `String` class's actual instance method. If that signature changed, the call site breaks statically, and no wrapper can intercept the call.

#### 2. Breaking Subclasses via Contravariance

Changes to method signatures in a superclass can break existing subclasses, even if the change seems minor.

*   **Example:** Tightening a parameter type in a core class method (e.g., changing a parameter from `num` to `int`).
*   **Why it's impossible to wrap:** Dart requires method overrides in subclasses to accept the same type or a supertype. If the superclass tightens the parameter, the existing override in the user's code becomes invalid, causing a compile-time error that a wrapper cannot fix.

#### 3. Removing Constructors

*   **Example:** The removal of the default `new List()` constructor in Dart 2.
*   **Why it's impossible to wrap:** Extensions cannot add constructors to existing classes. If a constructor is removed from `dart:core`, any code calling it fails at compile time.

#### 4. Changes Affecting Compile-Time Constants

*   **Example:** Removing the `const` keyword from a core library constructor.
*   **Why it's impossible to wrap:** User code that relied on this constructor in a constant context (e.g., switch cases, default parameter values) will break at compile time. A wrapper cannot force an operation to be compile-time evaluable if the underlying implementation no longer supports it.

### IV. Changes to Concurrency and Execution Timing

The `dart:async` library is deeply integrated with the Dart event loop and the `async/await` language features.

#### 1. The Sync/Async Boundary

Dart strictly enforces the separation between synchronous and asynchronous code.

*   **Why it's impossible to wrap:** If a synchronous operation is removed and replaced only by an asynchronous one (returning a `Future`), a wrapper cannot recreate the synchronous version. Pure Dart code cannot block the event loop to wait for a `Future` to complete synchronously (this is especially true on the web).

#### 2. Event Loop Scheduling and Timing

The precise order and timing of `Future` completion, microtasks, and the event loop are determined by the runtime scheduler.

*   **Why it's impossible to wrap:** If the runtime changes the scheduling algorithm or the timing of error delivery (e.g., changing a synchronous throw to an asynchronous error in a Future), Dart code cannot intervene to enforce the old timing semantics.

### V. Removal of Privileged or Platform Capabilities

Some core libraries rely on deep, non-public integration with the VM or the underlying platform (OS/Browser).

#### 1. Reflection (`dart:mirrors`)

`dart:mirrors` requires the runtime to preserve and expose program metadata. It is restricted or disabled on AOT platforms (like Flutter) for performance reasons.

*   **Why it's impossible to wrap:** If the compiler stops emitting the metadata or the runtime refuses access, a Dart wrapper cannot recreate the lost information. Reflection must be implemented *by* the runtime.

#### 2. Native Interop and Isolates

Changes to `dart:ffi` or `dart:isolate` often involve low-level VM mechanics.

*   **Why it's impossible to wrap:** Changes to FFI memory layouts or the mechanisms of memory isolation and message passing between isolates are implemented at the VM level and cannot be altered by a wrapper.

#### 3. Security Hardening

If `dart:io` or `dart:html` restrict access due to underlying platform security policies.

*   **Why it's impossible to wrap:** The Dart runtime (and any wrapper code) is constrained by the security sandbox of the environment. A wrapper cannot bypass VM-level or platform-level security restrictions.