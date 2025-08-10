# Test Scenarios

This directory contains test scenarios for the Change Detector, organized by the type of change (major or minor).

## Directory Structure

Each scenario follows this structure:
```
scenarios/
├── major/
│   └── <change_type>/
│       ├── README.md (describes the change)
│       └── ex1/
│           ├── before/ (code before the change)
│           └── after/  (code after the change)
└── minor/
    └── <change_type>/
        ├── README.md (describes the change)
        └── ex1/
            ├── before/ (code before the change)
            └── after/  (code after the change)
```

## Major Changes

Major changes are breaking changes that require a major version bump according to semantic versioning:

* [Removing a Declaration](major/removing_declaration/): Removing a public top-level declaration
* [Renaming a Declaration](major/renaming_declaration/): Renaming a public top-level declaration
* [Changing Variable Type](major/changing_variable_type_incompatible/): Changing a variable's type to an incompatible type
* [Changing Constant Value](major/changing_constant_value/): Changing the value of a public const variable
* [Changing Typedef](major/changing_typedef/): Changing a type alias to an incompatible type
* [Adding Abstract to Class](major/adding_abstract_to_class/): Making a concrete class abstract
* [Incompatible Superclass Change](major/incompatible_superclass_change/): Changing a class's superclass to an incompatible one
* [Adding Interface with Abstract Members](major/adding_interface_with_abstract_members/): Adding an interface with new abstract methods
* [Changing Mixin Constraints](major/changing_mixin_constraints/): Adding more restrictive constraints to a mixin
* [Changing Extension Target](major/changing_extension_target/): Making an extension's target type more restrictive
* [Removing Member](major/removing_member/): Removing a public method, field, getter, or setter from a class
* [Renaming Member](major/renaming_member/): Renaming a public method, field, getter, or setter in a class
* [Changing Member Scope](major/changing_member_scope/): Changing a member from static to instance or vice-versa
* [Making Field Final](major/making_field_final/): Making a mutable public field final
* [Changing Field Type](major/changing_field_type/): Changing a field's type to an incompatible type
* [Adding a Required Parameter](major/adding_required_parameter/): Adding a required parameter to an existing function
* [Making Parameter Required](major/making_parameter_required/): Changing an optional parameter to required
* [Removing Parameter](major/removing_parameter/): Removing a parameter from a function or method
* [Renaming Named Parameter](major/renaming_named_parameter/): Renaming a named parameter in a function or method
* [Changing Parameter Type to Non-Supertype](major/changing_parameter_type_non_supertype/): Changing a parameter's type to a more specific type
* [Changing Return Type to Non-Subtype](major/changing_return_type_non_subtype/): Changing a return type to an incompatible type
* [Changing Type Parameters](major/changing_type_parameters/): Adding or removing type parameters
* [Tightening Type Parameter Bound](major/tightening_type_parameter_bound/): Making a type parameter's bound more restrictive
* [Removing a Constructor](major/removing_constructor/): Removing a public constructor from a class
* [Changing Constructor Type](major/changing_constructor_type/): Changing a generative constructor to a factory constructor
* [Removing Enum Value](major/removing_enum_value/): Removing a value from a public enum
* [Changing Enum Values](major/changing_enum_values/): Renaming or reordering enum values

## Minor Changes

Minor changes are backward-compatible changes that require a minor version bump according to semantic versioning:

* [Adding a Declaration](minor/adding_declaration/): Adding a new public top-level declaration
* [Adding Concrete Members](minor/adding_concrete_members/): Adding new methods, getters, setters, or fields to a class
* [Adding Extension Methods](minor/adding_extension_methods/): Adding new methods to an extension
* [Adding an Optional Parameter](minor/adding_optional_parameter/): Adding an optional parameter to an existing function
* [Making Required Parameter Optional](minor/making_required_parameter_optional/): Making a required parameter optional
* [Changing Return Type to Subtype](minor/changing_return_type_to_subtype/): Changing a return type to a more specific type
* [Loosening Type Constraints](minor/loosening_type_constraints/): Making a type parameter's bound less restrictive
* [Adding Enum Value](minor/adding_enum_value/): Adding a new value to an existing enum
* [Adding Constructor](minor/adding_constructor/): Adding a new constructor to a class
* [Deprecating API](minor/deprecating_api/): Marking API elements as deprecated
