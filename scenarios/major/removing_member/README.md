# Removing a Member

## Description
Removing a public method, operator, field, getter, or setter from a class is a MAJOR breaking change.

## Impact
When a public member is removed from a class, consumer code that uses this member will fail to compile or cause runtime errors.

## Examples
This directory contains examples of removing members:
- Example 1: Removing a public method from a class

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Removing or Renaming Members:** A public method, operator, field, getter, or setter is removed or renamed.
