# Changing a Variable's Type to an Incompatible Type

## Description
Changing the type of a public variable to an incompatible type (i.e., a type that is not a supertype of the old type) is a MAJOR breaking change.

## Impact
When a variable's type is changed to an incompatible type, consumer code that uses this variable may fail to compile or cause runtime errors if the new type doesn't support the same operations as the old type.

## Examples
This directory contains examples of changing variable types incompatibly:
- Example 1: Changing a variable's type from a more general type to a more specific type

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Change a Variable's Type:** The type of a public variable is changed to an incompatible type (i.e., a type that is not a supertype of the old type).
