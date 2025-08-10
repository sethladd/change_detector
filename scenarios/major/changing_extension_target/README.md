# Changing an Extension's Target Type

## Description
Changing the target type (`on` clause) of a public extension to a more restrictive type is a MAJOR breaking change, as it causes the extension to no longer apply to types it previously did.

## Impact
When an extension's target type becomes more restrictive, consumer code that uses the extension on types that no longer match the target will fail to compile.

## Examples
This directory contains examples of changing extension target types:
- Example 1: Changing an extension's target type to a more restrictive type

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Changing an Extension's Target:** The target type (`on` clause) of a public extension is changed to a more restrictive type, causing it to no longer apply to types it previously did.
