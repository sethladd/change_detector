# Changing Member Scope

## Description
Changing a member from `static` to instance, or vice-versa, is a MAJOR breaking change.

## Impact
When a member's scope changes between static and instance, consumer code that accesses this member will fail to compile because the access syntax is different for static and instance members.

## Examples
This directory contains examples of changing member scope:
- Example 1: Changing a method from instance to static and vice-versa

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Changing Member Scope:** A member is changed from `static` to instance, or vice-versa.
