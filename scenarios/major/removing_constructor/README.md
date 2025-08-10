# Removing a Constructor

## Description
Removing a public constructor from a class is a MAJOR breaking change.

## Impact
When a constructor is removed, consumer code that uses this constructor to create instances of the class will fail to compile.

## Examples
This directory contains examples of removing constructors:
- Example 1: Removing a named constructor from a class

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Constructors:**
> - Removing a public constructor.
