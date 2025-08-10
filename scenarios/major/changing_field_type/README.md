# Changing a Field's Type

## Description
Changing the type of a public field to an incompatible type (i.e., a type that is not a subtype of the old type for the getter and not a supertype for the setter) is a MAJOR breaking change.

## Impact
When a field's type is changed to an incompatible type, consumer code that uses this field may fail to compile or cause runtime errors.

## Examples
This directory contains examples of changing field types:
- Example 1: Changing field types to incompatible types

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Changing a Field's Type:** The type of a public field is changed to an incompatible type. For a field to be compatible, its new type must be a subtype of the old type (for the getter) and a supertype of the old type (for the setter). A direct change to a non-subtype is breaking.
