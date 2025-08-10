# Making Type Parameter Bound More Restrictive

## Description
Making a type parameter's bound more restrictive is a MAJOR breaking change.

## Impact
When a generic type parameter's bound becomes more restrictive, consumer code that uses the generic with a type that no longer satisfies the new bound will fail to compile.

## Examples
This directory contains examples of tightening type parameter bounds:
- Example 1: Adding a more restrictive bound to a type parameter

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Changes to Generic Types:** Making a type parameter's bound more restrictive. For example, changing `<T>` to `<T extends num>` is a breaking change for any consumer that used the type with a non-`num` argument.
