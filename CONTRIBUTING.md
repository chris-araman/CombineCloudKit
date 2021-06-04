# Contributing to CombineCloudKit

I welcome high quality contributions from everyone! 🧑🏽‍💻👩🏿‍💻👨🏻‍💻

Submit [pull requests](https://github.com/chris-araman/CombineCloudKit/compare) from your fork of the repository. I may
suggest some changes or improvements or alternatives. To increase the chance that your pull request is accepted:

* Ensure your changes build, test, and lint successfully.
* Document any new public types or functions and include the generated documentation with your changes.
* Write tests for any new functionality and backfill tests to improve code coverage.
* Write clear, concise commit messages.
* Follow the surrounding code style.

## Building CombineCloudKit

Use the Swift Package Manager to build:

```bash
swift build
```

## Testing CombineCloudKit

🚧 Because CloudKit entitlements are required in order to validate functionality, some considerable work remains to wire
this up automatically to `swift test`. This is a work in progress. Once testing with entitlements is working, it is a
goal to achieve > 90% code coverage.

Use the Swift Package Manager to test:

```bash
swift test
```

## Linting CombineCloudKit

We check for lint using several tools, many of which are installed using [Homebrew](https://brew.sh). Please fix any
issues reported here before submitting a pull request.

Check for lint:

```bash
script/lint
```

## Documentation

Please include documentation in any new public types or functions using
[markup](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/) with
appropriate [syntax](https://github.com/apple/swift/blob/main/docs/DocumentationComments.md).

Generate new documentation pages:

```bash
script/build_docs
```

Commit the new documentation pages with your changes.
