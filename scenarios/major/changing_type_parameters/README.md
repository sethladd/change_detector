# Adding or Removing Type Parameters

## Description
Adding or removing type parameters from a public generic class, mixin, extension, or function is a MAJOR breaking change.

## Impact
When type parameters are added or removed, consumer code that uses the generic type will fail to compile because the number of type arguments no longer matches the declaration.

## Examples
This directory contains examples of adding and removing type parameters:
- Example 1: Adding and removing type parameters from classes and functions

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Changes to Generic Types:** Modifications to the type parameters of a public generic class, mixin, extension, or function are breaking if they include: Adding or removing a type parameter.
