# Adding a Super-Interface with New Abstract Members

## Description
Adding a super-interface to a public class (or one of its existing supertypes) that introduces new abstract members is a MAJOR breaking change for consumers who implement the class's interface.

## Impact
When a new interface with abstract members is added to a class, consumer code that implements this class will fail to compile because it must now implement these new abstract members.

## Examples
This directory contains examples of adding interfaces with abstract members:
- Example 1: Adding a new interface to a class that introduces abstract methods

## Related API Documentation
According to the [Dart API Major Change documentation](../../api_major_change.md):
> **Changing Supertype Hierarchies:** A super-interface is added to a public class (or one of its existing supertypes) that introduces new abstract members. This is a breaking change for consumers who implement the class's interface.
