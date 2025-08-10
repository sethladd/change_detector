# Changing Parameter Type to Non-Supertype

## Description
Changing a parameter's type to a non-supertype of the original type is a MAJOR breaking change.

## Impact
When a parameter type changes to a non-supertype, existing consumer code that passes values of the original type will fail to compile or cause runtime errors, as the parameter now expects a more specific type.

## Examples
This directory contains examples of changing parameter types in an incompatible way:
- Example 1: Changing a parameter from Object to String (narrowing type)

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Parameters:**
> - Changing a parameter's type to a non-supertype. For example, changing a parameter of type `Object` to `String` is a breaking change because consumers could no longer pass a non-`String` object.
