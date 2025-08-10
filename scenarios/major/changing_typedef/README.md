# Changing a Type Alias (typedef)

## Description
Changing the underlying type of a public `typedef` to a new type that is not a subtype of the original is a MAJOR breaking change.

## Impact
When a typedef's underlying type changes incompatibly, consumer code that uses this typedef may fail to compile or cause runtime errors, as the new type may not support the same operations as the old type.

## Examples
This directory contains examples of changing typedefs:
- Example 1: Changing a typedef's underlying type to an incompatible type

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Changing a Type Alias:** The underlying type of a public `typedef` is changed to a new type that is not a subtype of the original.
