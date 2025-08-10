# Changing a Mixin's Constraints

## Description
Adding a new, more restrictive superclass constraint (an `on` clause) to a public mixin is a MAJOR breaking change, as it can prevent the mixin from being applied in existing use cases.

## Impact
When a mixin's constraints are made more restrictive, consumer code that applies this mixin to classes that don't satisfy the new constraint will fail to compile.

## Examples
This directory contains examples of changing mixin constraints:
- Example 1: Adding a more restrictive constraint to a mixin

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Changing a Mixin's Constraints:** A new, more restrictive superclass constraint (an `on` clause) is added to a public mixin, which can prevent it from being applied in existing use cases.
