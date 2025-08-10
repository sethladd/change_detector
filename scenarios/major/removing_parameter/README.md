# Removing a Parameter

## Description
Removing a parameter from a public function, method, or constructor is a MAJOR breaking change.

## Impact
When a parameter is removed, consumer code that passes this parameter will fail to compile.

## Examples
This directory contains examples of removing parameters:
- Example 1: Removing parameters from functions and methods

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Parameters:** Removing any parameter.
