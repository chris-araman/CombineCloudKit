---
name: Bug report
about: Create a report to help improve CombineCloudKit
title: ":bug: "
labels: bug
assignees: chris-araman
---

## Describe the bug

A clear and concise description of the problem.

## How to reproduce

Steps to follow to reproduce the problem:

1. Do a thing.
1. Then do this.
1. Then this.

Please include sample code that reproduces the problem.

```swift
  database
    .performQuery(ofType: "ToDoItem", where: NSPredicate(true))
    .sink { records in
      XCTAssertGreaterThan(records.count, 0)
    }
```

## Unexpected behavior

A clear and concise description of what happened that you did not expect to happen.
> CombineCloudKit does not return any `CKRecord` results. The assertion fails.

## Expected behavior

A clear and concise description of what you expected to happen.
> I expect to receive at least one `CKRecord` in `sink`.

## Environment

- CombineCloudKit version
- macOS, iOS, watchOS, or tvOS version
- Swift version
- Xcode version

> CombineCloudKit 0.1.0, macOS Catalyst 11.2, Swift 5.3, Xcode 12.4

## Additional context

Any other context about the problem.
