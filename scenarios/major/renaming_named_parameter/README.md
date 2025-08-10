# Renaming a Named Parameter

## Description
Renaming a named parameter in a public function, method, or constructor is a MAJOR breaking change.

## Impact
When a named parameter is renamed, consumer code that calls the function using the old parameter name will fail to compile.

## Examples
This directory contains examples of renaming named parameters:
- Example 1: Renaming named parameters in functions and methods

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Parameters:** Renaming a named parameter.
