# Renaming a Member

## Description
Renaming a public method, operator, field, getter, or setter in a class is a MAJOR breaking change.

## Impact
When a public member is renamed, consumer code that uses this member will fail to compile.

## Examples
This directory contains examples of renaming members:
- Example 1: Renaming methods, fields, getters, and setters in a class

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Removing or Renaming Members:** A public method, operator, field, getter, or setter is removed or renamed.
