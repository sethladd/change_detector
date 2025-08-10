# Making a Mutable Field Final

## Description
Changing a mutable public field (one with a public setter) to be `final` or `const` is a MAJOR breaking change.

## Impact
When a mutable field is made final, consumer code that attempts to modify this field will fail to compile, as the field can no longer be changed after initialization.

## Examples
This directory contains examples of making fields final:
- Example 1: Changing a mutable field to be final

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Restricting a Field:** A mutable public field (one with a public setter) is changed to be `final` or `const`, as this effectively removes the setter.
