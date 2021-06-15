# Contributing to CombineCloudKit

There are three ways in which you can contribute to the project.

## ❤️ Sponsorship

[![Sponsor](https://img.shields.io/badge/Sponsor-chris--araman-slateblue?logo=github&style=flat-square)](https://github.com/sponsors/chris-araman)

Your sponsorship will enable me to spend more time contributing to open source projects. Thanks for your support!

## 🐛 Issues

Submit [bug reports](https://github.com/chris-araman/CombineCloudKit/issues/new?template=bug_report.md) and
[feature requests](https://github.com/chris-araman/CombineCloudKit/issues/new?template=feature_request.md) using the
provided templates. I can't guarantee I can resolve everything reported, but I'd like the opportunity to try.
Sponsorship can be quite motivating. 😊

## 🧑🏽‍💻👩🏿‍💻👨🏻‍💻 Pull Requests

I welcome high quality pull requests from everyone! 🦄

Pull requests are preferred over bug reports and feature requests. ✨

Submit [pull requests](https://github.com/chris-araman/CombineCloudKit/compare) from your fork of the repository. I may
suggest some changes or improvements or alternatives. To increase the chance that your pull request is accepted:

* Ensure your changes build, test, and lint successfully.
* Document any new public types or functions and include the generated documentation with your changes.
* Write tests for any new functionality and backfill tests to improve code coverage.
* Write clear, concise commit messages.
* Follow the surrounding code style.

### 🛠 Building CombineCloudKit

Use the Swift Package Manager to build:

```bash
swift build
```

### ✅ Testing CombineCloudKit

Unit testing is accomplished using mock CloudKit types.

[![Coverage](https://img.shields.io/codecov/c/github/chris-araman/CombineCloudKit/main?style=flat-square)](https://app.codecov.io/gh/chris-araman/CombineCloudKit/)

> 🚧 Integration testing against the CloudKit API and service will require app entitlements. Some work
remains to wire this up automatically to `swift test`.

Use the Swift Package Manager to test:

```bash
swift test
```

### 🧹 Linting CombineCloudKit

We check for lint using several tools, many of which are installed using [Homebrew](https://brew.sh). Please fix any
issues reported here before submitting a pull request.

Check for lint:

```bash
script/lint
```

### 📘 Documentation

CombineCloudKit is 💯% [documented](https://combinecloudkit.hiddenplace.dev). Please include documentation for any new
public types or functions using
[markup](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/) with
appropriate [syntax](https://github.com/apple/swift/blob/main/docs/DocumentationComments.md).

Generate new documentation pages:

```bash
script/build_docs
```

Commit the new documentation pages with your changes.
