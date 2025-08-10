# Making an Optional Parameter Required

## Description
Changing an existing optional parameter to be required is a MAJOR breaking change.

## Impact
When an optional parameter becomes required, consumer code that calls the function without providing the parameter will fail to compile.

## Examples
This directory contains examples of making parameters required:
- Example 1: Changing optional positional and named parameters to required

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Parameters:** Changing an existing optional parameter to be required.
