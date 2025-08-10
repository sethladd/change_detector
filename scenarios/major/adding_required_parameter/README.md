# Adding a Required Parameter

## Description
Adding a new required parameter (either positional or named) to a public function or method is a MAJOR breaking change.

## Impact
When a required parameter is added, existing code that calls the function will fail to compile because it's not providing the newly required parameter. This is a breaking change.

## Examples
This directory contains examples of adding required parameters:
- Example 1: Adding a required parameter to a function

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Parameters:**
> - Adding a new required parameter (either positional or named).
