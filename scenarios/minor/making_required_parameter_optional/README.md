# Making a Required Parameter Optional

## Description
Changing an existing required parameter to be optional is a MINOR change.

## Impact
When a required parameter is made optional, all existing call sites that were already providing a value for this parameter will continue to work correctly. This is a backward-compatible change.

## Examples
This directory contains examples of making required parameters optional:
- Example 1: Making a required parameter optional by providing a default value

## Related API Documentation
According to the [Dart API Minor Change documentation](../../api_minor_change.md):
> **Changing a Required Parameter to Optional:** An existing required parameter can be made optional, as all existing call sites will already be providing a value for it.
