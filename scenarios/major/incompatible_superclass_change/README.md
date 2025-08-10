# Incompatible Superclass Change

## Description
Changing the superclass of a public class to an incompatible one that doesn't provide a superset of the original superclass's public instance members is a MAJOR breaking change.

## Impact
When a class's superclass changes to one that doesn't provide the same members, consumer code that uses the inherited members from the original superclass will fail to compile or cause runtime errors.

## Examples
This directory contains examples of incompatible superclass changes:
- Example 1: Changing a class's superclass to one with fewer/different public members

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Changing Supertype Hierarchies:** The superclass of a public class is changed, and the new superclass does not provide a superset of the original superclass's public instance members.
