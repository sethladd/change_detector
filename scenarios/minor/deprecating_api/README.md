# Deprecating API

## Description
Marking any part of the public API as deprecated (e.g., using the `@deprecated` annotation) is a MINOR change.

## Impact
When an API element is marked as deprecated, existing code continues to work correctly but will receive warnings. This signals to consumers that the feature will be removed in a future MAJOR version release.

## Examples
This directory contains examples of deprecating API elements:
- Example 1: Deprecating classes, methods, and functions

## Related API Documentation
According to the [Dart API Minor Change documentation](../../api_minor_change.md):
> **Deprecating Public API:** Marking any part of the public API as deprecated (e.g., using the `@deprecated` annotation). This does not break existing code but signals to consumers that the feature will be removed in a future MAJOR version release.
