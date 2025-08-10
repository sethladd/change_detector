# Changing Constructor Type

## Description
Changing a generative constructor to a factory constructor is a MAJOR breaking change, as this prevents subclasses from being able to call `super()`.

## Impact
When a generative constructor is changed to a factory constructor, consumer code that extends the class and calls `super()` in its constructor will fail to compile.

## Examples
This directory contains examples of changing constructor types:
- Example 1: Changing a generative constructor to a factory constructor

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Constructors:** Changing a generative constructor to a factory constructor, as this prevents subclasses from being able to call `super()`.
