// Simple example demonstrating declarations that have been renamed
library example;

/// Class renamed from OriginalClass - MAJOR breaking change [Major.2]
class RenamedClass {
  void method() {}
}

/// Function renamed from originalFunction - MAJOR breaking change [Major.2]
void renamedFunction() {}

/// Constant renamed from originalConstant - MAJOR breaking change [Major.2]
const int renamedConstant = 42;
