# Renaming a Declaration

## Description
Renaming a public top-level declaration (class, function, variable, etc.) is a MAJOR breaking change.

## Impact
When a public API element is renamed, any consumer code that references this declaration by its original name will fail to compile, resulting in errors.

## Examples
This directory contains examples of renaming different kinds of top-level declarations:
- Example 1: Renaming a public class

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> Changes to any public, exported declaration at the library level are breaking if they:
> - **Rename a Declaration:** A public top-level declaration is renamed.
