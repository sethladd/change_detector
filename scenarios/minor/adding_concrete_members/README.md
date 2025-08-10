# Adding Concrete Members

## Description
Adding new public concrete instance methods, getters, setters, or fields to an existing public class or mixin is a MINOR change, provided the class is not intended to be implemented by consumers.

## Impact
When new concrete members are added to a class, consumer code that extends the class will gain access to these new members without breaking. However, code that implements the class's interface may need to be updated to implement these new members.

## Examples
This directory contains examples of adding concrete members:
- Example 1: Adding new methods, getters, setters, and fields to a class

## Related API Documentation
According to the [Dart API Minor Change documentation](../../api_minor_change.md):
> **Adding New Concrete Members:**
>   - Adding a new public concrete instance method, getter, setter, or field to an existing public class or mixin. **Note:** This can be a breaking change for consumers who `implement` the class's interface rather than `extend` it, as their implementation will become incomplete. Therefore, this should only be considered a Minor change for classes that are not intended to be implemented by consumers (e.g., abstract classes with a base class).
>   - Adding a new public `static` method, getter, setter, or field to a class, mixin, or extension.
