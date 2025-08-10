# Changing Return Type to Subtype

## Description
Changing the return type of a public function or getter to a subtype of the original return type is a MINOR change.

## Impact
When a return type is changed to a subtype, existing code that uses the function continues to work correctly because the returned value is still compatible with the original type. This is a covariant change and is backward-compatible.

## Examples
This directory contains examples of changing return types to subtypes:
- Example 1: Changing a return type from `num` to `int`

## Related API Documentation
According to the [Dart API Minor Change documentation](../../api_minor_change.md):
> **Changing a Return Type to a Subtype:** Changing the return type of a public function or getter to a subtype of the original is a safe, covariant change from the caller's perspective. For instance, changing a return type from `num` to `int` is backward-compatible.
