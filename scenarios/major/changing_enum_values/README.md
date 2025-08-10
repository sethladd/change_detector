# Renaming or Reordering Enum Values

## Description
Renaming an enum value or reordering enum values are both MAJOR breaking changes.

## Impact
When an enum value is renamed, consumer code that references this value by name will fail to compile. When enum values are reordered, this changes the public `index` of each value, which can cause runtime errors in code that relies on these indices.

## Examples
This directory contains examples of changing enum values:
- Example 1: Renaming and reordering enum values

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> Because enums are a fixed set of constants, the following changes to a public enum are breaking:
> - Renaming an enum value.
> - Reordering enum values, as this changes the public `index` of each value.
