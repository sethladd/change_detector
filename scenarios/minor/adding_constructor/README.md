# Adding a Constructor

## Description
Adding a new public constructor to a class is a MINOR change.

## Impact
When a new constructor is added, existing code that uses the class continues to work correctly because it's still using the existing constructors. This is a backward-compatible change that adds new functionality.

## Examples
This directory contains examples of adding constructors:
- Example 1: Adding a new named constructor to a class

## Related API Documentation
According to the [Dart API Minor Change documentation](../../api_minor_change.md):
> **Adding New Constructors:** Adding a new public constructor to a class (e.g., a new named constructor or a factory constructor) is a non-breaking addition of functionality.
