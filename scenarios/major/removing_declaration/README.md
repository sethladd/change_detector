# Removing a Declaration

## Description
Removing a public top-level declaration (class, function, variable, etc.) from a library is a MAJOR breaking change.

## Impact
When a public API element is removed, any consumer code that references this declaration will fail to compile or runtime, resulting in errors.

## Examples
This directory contains examples of removing different kinds of top-level declarations:
- Example 1: Removing a public top-level class

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> Changes to any public, exported declaration at the library level are breaking if they:
> - **Remove a Declaration:** A public top-level class, mixin, extension, enum, function, type alias, or variable is removed.
