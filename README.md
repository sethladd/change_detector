# Dart API Change Detector

**Do not trust this project. It is an experiment and may be deleted at any time.**

This project is a prototype of a tool that analyzes two versions of a Dart
library and determines if the API changes between them constitute a "major" or
"minor" change, according to semantic versioning. This can help automate the
process of deciding whether to bump a package's major or minor version number.

## How it Works

The tool works by generating a checksum of a library's public API. It can then
compare two checksums (e.g., "before" and "after") to identify the nature of
the changes.

The core logic for this can be found in `lib/src/api_differ.dart`.

## Critical Files and Directories

*   `pubspec.yaml`: Defines the project's dependencies and metadata.
*   `bin/change_detector.dart`: The command-line entry point for the tool.
*   `lib/src/`: Contains the core logic for the change detection.
    *   `api_checksum.dart`: Responsible for generating the API checksum.
    *   `api_differ.dart`: Responsible for comparing two API checksums and
        identifying changes.
*   `scenarios/`: Contains a collection of "before" and "after" code snippets
    that represent different types of API changes (e.g., major, minor). These
    are used for testing and validation.
*   `test/`: Contains the tests for the project, including a test runner for the
    scenarios.

## Disclaimer

This is an experimental project. The results may not be accurate, and the API
of this tool itself is subject to breaking changes without notice. Do not use
this in a production environment.
