# Adding Abstract Keyword to a Class

## Description
Adding the `abstract` keyword to a previously concrete, instantiable class is a MAJOR breaking change.

## Impact
When a concrete class is made abstract, consumer code that directly creates instances of that class will fail to compile. This is because abstract classes cannot be directly instantiated.

## Examples
This directory contains examples of adding the `abstract` keyword to a class:
- Example 1: Making a concrete class abstract

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> Structural changes to public type declarations are breaking in the following cases:
> - **Adding `abstract`:** A concrete, instantiable public class is made `abstract`, as this prevents consumers from creating instances of it directly.
