# Changing a Constant Value

## Description
Changing the value of a public `const`-declared variable is a MAJOR breaking change.

## Impact
When a constant value changes, it can break consumer code that depends on the specific value. In Dart, constants are often inlined at compile-time, so changing the value can lead to inconsistencies and unexpected behavior.

## Examples
This directory contains examples of changing constant values:
- Example 1: Changing the value of a const variable

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> Changes to any public, exported declaration at the library level are breaking if they:
> - **Change a Constant's Value:** The value of a public `const`-declared variable is changed.
