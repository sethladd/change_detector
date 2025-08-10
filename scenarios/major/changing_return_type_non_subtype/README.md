# Changing Return Type to Non-Subtype

## Description
Changing the return type of a function or getter to a type that is not a subtype of the original return type is a MAJOR breaking change.

## Impact
When a function's return type changes to a non-subtype, consumer code that relies on the original return type may fail to compile or cause runtime errors, as the new type may not support the same operations.

## Examples
This directory contains examples of changing return types to non-subtypes:
- Example 1: Changing function and method return types to incompatible types

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Return Values:** Changing the return type of a function or getter to a type that is not a subtype of the original return type.
