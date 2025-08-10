# Test Runner Plan for Scenario Validation

This document outlines the plan for creating a test runner that systematically tests all scenarios in the `scenarios` directory to verify that the change detector correctly identifies major and minor changes.

## 1. Test Runner Structure

```
test/
  scenarios_test.dart   # Main test file that runs all scenario tests
  scenario_runner.dart  # Helper class for running scenario tests
```

## 2. Implementation Approach

### A. `ScenarioRunner` Class
- **Purpose**: Encapsulate the logic for testing a single scenario
- **Key Methods**:
  - `testScenario(String scenarioPath)`: Test a specific scenario
  - `extractExpectedChangeType(String afterCode)`: Parse comments to determine expected change type
  - `runChangeDetector(String beforePath, String afterPath)`: Run the change detector on before/after code
  - `compareResults(ChangeType expected, ChangeType actual)`: Verify results match expectations

### B. `scenarios_test.dart` Implementation
1. **Discovery Phase**:
   - Find all scenario directories using `Directory('scenarios').listSync()`
   - For each scenario category (major/minor), find all scenario types
   - For each scenario type, find all examples

2. **Testing Phase**:
   - For each example, run the `ScenarioRunner` to:
     - Load the before/after code
     - Extract expected change type from comments, found in the after code
     - Run the change detector
     - Compare actual results with expected results

3. **Reporting**:
   - Generate a summary of passed/failed tests
   - Provide detailed error messages for failed tests

## 3. Comment Format for Expected Changes

The test runner will look for specific comment formats in the `after/example.dart` files.

Examples of the comment format:

```dart
/// Added extension - MINOR change
/// Method with added required parameter - MAJOR breaking change
```

These comments will be parsed to determine the expected change type.

## 4. Integration with Existing Code

The test runner will:
1. Use the existing `ApiDiffer` class to analyze the before/after code
2. Extract the `ChangeType` from the `DiffResult` returned by the differ
3. Compare this with the expected change type from the comments

## 5. Implementation Steps

1. Create the basic test structure
2. Implement the scenario discovery logic
3. Implement the `ScenarioRunner` class
4. Add test assertions and reporting
5. Run tests on all scenarios
6. Add detailed error reporting for failed tests

## 6. Potential Challenges and Solutions

1. **Challenge**: Handling different file structures or missing files  
   **Solution**: Add robust error handling and validation

2. **Challenge**: Parsing comments correctly  
   **Solution**: Use regex patterns to reliably extract expected change types

3. **Challenge**: Integrating with the existing change detector  
   **Solution**: Study the current API and ensure proper usage

4. **Challenge**: Dealing with scenarios that might have multiple change types  
   **Solution**: Support multiple expected change types in comments if needed
