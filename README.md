# ⛅️ CombineCloudKit

Swift Combine extensions for asynchronous CloudKit record processing. Designed for simplicity.

[![Swift](https://img.shields.io/endpoint?label=swift&logo=swift&style=flat-square&url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fchris-araman%2FCombineCloudKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/chris-araman/CombineCloudKit)
[![Platforms](https://img.shields.io/endpoint?label=platforms&logo=apple&style=flat-square&url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fchris-araman%2FCombineCloudKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/chris-araman/CombineCloudKit)
[![License](https://img.shields.io/github/license/chris-araman/CombineCloudKit?style=flat-square&color=informational)](https://github.com/chris-araman/CombineCloudKit/blob/main/LICENSE.md)
[![Release](https://img.shields.io/github/v/tag/chris-araman/CombineCloudKit?style=flat-square&color=informational&label=release&sort=semver)](https://github.com/chris-araman/CombineCloudKit/releases)
[![Lint, Build, & Test](https://img.shields.io/github/workflow/status/chris-araman/CombineCloudKit/Lint,%20Build,%20&%20Test/main?style=flat-square&logo=github)](https://github.com/chris-araman/CombineCloudKit/actions/workflows/build.yml?query=branch%3Amain)

CombineCloudKit exposes [CloudKit](https://developer.apple.com/documentation/cloudkit) operations as
[Combine](https://developer.apple.com/documentation/combine) publishers. Publishers can be used to process values over
time, using Combine's declarative API.

## Usage

CombineCloudKit is a [Swift Package](https://developer.apple.com/documentation/swift_packages). Add a dependency on
CombineCloudKit to your project using
[Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) or the
[Swift Package Manager](https://swift.org/package-manager/).

```swift
import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(name: "CombineCloudKit", url: "https://github.com/chris-araman/CombineCloudKit.git", .upToNextMajor(from: "0.0.1"))
    ]
)
```

Combine allows you to chain value processing [Publishers](https://developer.apple.com/documentation/combine/publisher)
for one or more [Subscribers](https://developer.apple.com/documentation/combine/subscriber). Here, we perform a query on
our [`CKDatabase`](https://developer.apple.com/documentation/cloudkit/ckdatabase), then process the results
asynchronously. As each [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord) is read from the
database, it is passed to the [`map`](https://developer.apple.com/documentation/combine/publishers/merge/map(_:)-6v8fv)
publisher which publishes the value of the record's name field. Any errors in the chain so far can be handled in the
catch publisher, which passes [`CKRecordValue`](https://developer.apple.com/documentation/cloudkit/ckrecordvalue) values
along to our [`sink`](https://developer.apple.com/documentation/combine/fail/sink(receivevalue:)) subscriber where the
final values are processed.

```swift
import CloudKit
import Combine
import CombineCloudKit

func queryDueItems(database: CKDatabase, due: Date) {
  let cancellable = database
    .performQuery(ofType: "ToDoItem", where: NSPredicate(format: "due >= %@", due))
    .map { record: CKRecord -> CKRecordValue in
      // Map each ToDoItem to its Name
      print("Received record: \(record)")
      return record["Name"]
    }.catch { error: Error in
      // Handle any upstream error
      print("Received error: \(error)")
    }.sink { value: CKRecordValue in
      // Process the Name of each ToDoItems
      print("Received result: \(value)")
    }

  // ...
}
```

Note that the [`Cancellable`](https://developer.apple.com/documentation/combine/cancellable) subscriber from
[`sink`](https://developer.apple.com/documentation/combine/fail/sink(receivevalue:)) will cancel the upstream publishers
when it is deinitialized. Take care to ensure that your subscribers live long enough to process values. If a
CombineCloudKit publisher is cancelled before it is finished emitting values, the underlying
[`CKOperation`](https://developer.apple.com/documentation/cloudkit/ckoperation) will be cancelled. This may be desirable
when performing a query and processing only the first few results. However, failing to wait for completion of a `save`,
`delete`, or `modify` operation may result in undesirable cancellation.

## Building

```bash
swift build
```

## Testing

```bash
swift test
```

🚧 Because CloudKit entitlements are required in order to validate functionality, some considerable work remains to wire
this up automatically to `swift test`. This is a work in progress. Once testing with entitlements is working, it is a
goal to achieve > 90% code coverage.

## Documentation

💯% [documented](https://chris-araman.github.io/CombineCloudKit/) using [Jazzy](https://github.com/realm/jazzy).
Hosted by [GitHub Pages](https://pages.github.com).

## Further Reading

To learn more about Combine and CloudKit, watch these videos from WWDC:

* [Introducing Combine](https://developer.apple.com/videos/play/wwdc2019/722)
* [Combine in Practice](https://developer.apple.com/videos/play/wwdc2019/721)

...or review Apple's documentation:

* [CloudKit Overview](https://developer.apple.com/icloud/cloudkit/)
* [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
* [Combine Documentation](https://developer.apple.com/documentation/combine)

## License

CombineCloudKit was created by [Chris Araman](https://github.com/chris-araman). It is published under the
[MIT license](LICENSE.md).
