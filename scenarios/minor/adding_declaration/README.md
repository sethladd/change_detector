# Adding a New Public Declaration

## Description
Adding a new public top-level declaration (class, function, variable, etc.) to a library is a MINOR change.

## Impact
When a new public API element is added, existing consumer code continues to work correctly because it doesn't reference the new declaration yet. This is a backward-compatible change.

## Examples
This directory contains examples of adding new declarations:
- Example 1: Adding new public classes, functions, and variables

## Related API Documentation
According to the [Dart API Minor Change documentation](../../api_minor_change.md):
> **Adding New Public Declarations:**
> - Adding a new public class, mixin, extension, enum, or type alias (`typedef`).
> - Adding a new public top-level function.
> - Adding a new public top-level variable (`var`, `final`).
