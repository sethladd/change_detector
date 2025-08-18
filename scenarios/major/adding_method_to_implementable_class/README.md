# Adding Method to Implementable Class

**Change ID:** Major.29  
**Category:** Major (Breaking Change)

## Description

Adding a new method to a public class breaks downstream code that implements the class's interface. In Dart, every class implicitly defines an interface, and any code that implements that interface must provide concrete implementations of all methods. When a new method is added to a class, existing implementors will fail to compile because they lack the implementation for the new method.

## Scenario

This scenario demonstrates the breaking change that occurs when a method is added to a class that consumers are implementing.

### Before (ex1/before/)

The `Storage` class has only one method:
- `String? read(String key)` - reads data from storage

Consumer classes (`MemoryStorage` and `FileStorage`) implement this interface by providing only the `read` method.

### After (ex1/after/)

The `Storage` class now has two methods:
- `String? read(String key)` - existing method
- `void write(String key, String value)` - **NEW METHOD**

The addition of the `write` method breaks existing implementations because:

1. `MemoryStorage` no longer compiles - missing `write` implementation
2. `FileStorage` no longer compiles - missing `write` implementation

## Why This Is Breaking

In Dart, when you declare `class MyClass implements SomeInterface`, you're saying that `MyClass` will provide concrete implementations of **all** methods declared in `SomeInterface`. Adding a new method to the interface means all existing implementors must be updated to include the new method, which is a breaking change.

## Impact on Consumers

Consumers who have implemented the original interface will experience:
- **Compilation failures** with errors like "Missing concrete implementation of 'Storage.write'"
- **Forced code changes** to add implementations for the new method
- **Potential runtime behavior changes** if the new method has semantic requirements

## Mitigation Strategies

To avoid this breaking change, API authors can:

1. **Use abstract base classes with default implementations**
2. **Create new interfaces instead of modifying existing ones**
3. **Use extension methods for new functionality**
4. **Make new methods optional with default implementations** (though this doesn't work for abstract classes)

## Detection

The change detector should identify this as a `Major.29` breaking change when:
- A new method is added to a public class
- The class is likely to be implemented by consumers (abstract classes, interfaces)
- The method doesn't have a default implementation (abstract or concrete)
