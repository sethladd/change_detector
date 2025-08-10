# Adding an Optional Parameter

## Description
Adding a new optional parameter (either positional or named) to a public function or method is a MINOR change.

## Impact
When an optional parameter is added, existing code that calls the function without this parameter continues to work correctly because the parameter has a default value. This is a backward-compatible change.

## Examples
This directory contains examples of adding optional parameters:
- Example 1: Adding an optional named parameter to a function

## Related API Documentation
According to the [Dart API Minor Change documentation](../../api_minor_change.md):
> **Adding Optional Parameters:** Adding a new optional parameter (either positional or named) to a public function or method. Existing calls will continue to work, using the parameter's default value.
