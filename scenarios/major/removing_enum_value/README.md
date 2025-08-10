# Removing an Enum Value

## Description
Removing a value from a public enum is a MAJOR breaking change.

## Impact
When an enum value is removed, consumer code that references this value will fail to compile. This is especially problematic for switch statements that expect specific enum values.

## Examples
This directory contains examples of removing enum values:
- Example 1: Removing a value from an enum

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> Because enums are a fixed set of constants, the following changes to a public enum are breaking:
> - Removing an enum value.
