# Adding an Enum Value

## Description
Adding a new value to an existing public enum is a MINOR change.

## Impact
When a new enum value is added, existing code that uses the enum continues to work correctly. While it may cause switch statements to become non-exhaustive, this results in a static warning rather than a compile-time error, and is considered backward-compatible.

## Examples
This directory contains examples of adding enum values:
- Example 1: Adding a value to an existing enum

## Related API Documentation
According to the [Dart API Minor Change documentation](../../api_minor_change.md):
> **Adding New Enum Values:** Adding a new value to an existing public `enum`. While this may cause `switch` statements in consumer code to become non-exhaustive, this results in a static warning, not a compile-time error, and is considered backward-compatible.
