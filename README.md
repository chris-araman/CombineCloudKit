# ⛅️ CombineCloudKit

Swift Combine extensions for reactive CloudKit record processing. Designed for simplicity.

[![Swift](https://img.shields.io/endpoint?label=swift&logo=swift&style=flat-square&url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fchris-araman%2FCombineCloudKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/chris-araman/CombineCloudKit)
[![Platforms](https://img.shields.io/endpoint?label=platforms&logo=apple&style=flat-square&url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fchris-araman%2FCombineCloudKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/chris-araman/CombineCloudKit)
[![License](https://img.shields.io/github/license/chris-araman/CombineCloudKit?style=flat-square&color=informational)](https://github.com/chris-araman/CombineCloudKit/blob/main/LICENSE.md)
[![Release](https://img.shields.io/github/v/tag/chris-araman/CombineCloudKit?style=flat-square&color=informational&label=release&sort=semver)](https://github.com/chris-araman/CombineCloudKit/releases)

[![Lint | Build | Test](https://img.shields.io/github/workflow/status/chris-araman/CombineCloudKit/Continuous%20Integration/main?style=flat-square&logo=github&label=lint%20%7C%20build%20%7C%20test)](https://github.com/chris-araman/CombineCloudKit/actions/workflows/ci.yml?query=branch%3Amain)
[![Coverage](https://img.shields.io/codecov/c/github/chris-araman/CombineCloudKit/main?style=flat-square&color=informational)](https://app.codecov.io/gh/chris-araman/CombineCloudKit/)

CombineCloudKit exposes [CloudKit](https://developer.apple.com/documentation/cloudkit) operations as
[Combine](https://developer.apple.com/documentation/combine) publishers. Publishers can be used to process values over
time, using Combine's declarative API.

## 📦 Adding CombineCloudKit to Your Project

CombineCloudKit supports [Swift Package Manager](https://developer.apple.com/documentation/swift_packages),
[CocoaPods](https://cocoapods.org/about), and [Carthage](https://github.com/Carthage/Carthage). You can use whichever
you prefer, but Swift Package Manager is most likely to be supported in the future.

### Swift Package Manager

Add a dependency on CombineCloudKit to your
[`Package.swift`](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html) using
[Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) or the
[Swift Package Manager](https://swift.org/package-manager/). Optionally, specify a
[version requirement](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html#package-dependency-requirement).

```swift
dependencies: [
  .package(url: "https://github.com/chris-araman/CombineCloudKit.git", from: "1.0.0")
]
```

Then resolve the dependency:

```bash
swift package resolve
```

To update to the latest CombineCloudKit version compatible with your version requirement:

```bash
swift package update CombineCloudKit
```

### CocoaPods

Add a [dependency](https://guides.cocoapods.org/using/using-cocoapods.html#adding-pods-to-an-xcode-project) on
CombineCloudKit to your [`Podfile`](https://guides.cocoapods.org/using/the-podfile.html). Optionally, specify a
[version requirement](https://guides.cocoapods.org/using/the-podfile.html#specifying-pod-versions).

```ruby
pod 'CombineCloudKit', '~>1.0'
```

Then [install](https://guides.cocoapods.org/using/pod-install-vs-update.html) the dependency:

```bash
pod install
```

To [update](https://guides.cocoapods.org/using/pod-install-vs-update.html) to the latest CombineCloudKit version
compatible with your version requirement:

```bash
pod update CombineCloudKit
```

### Carthage

Add a dependency on CombineCloudKit to your
[`Cartfile`](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).
Optionally, specify a
[version requirement](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#version-requirement).

```ogdl
github "chris-araman/CombineCloudKit" ~> 1.0
```

Because Carthage assumes dependencies are provided as shared frameworks, but Swift Package Manager builds only libraries
or executables, we have to generate an `.xcodeproj` for Carthage to use.

> ⚠️ The `generate-xcodeproj` command has been deprecated. This solution may stop working in a future release of the Swift
> Package Manager.

```bash
carthage bootstrap --no-build
pushd Carthage/Checkouts/CombineCloudKit && swift package generate-xcodeproj && popd
carthage bootstrap --use-xcframeworks
```

To update to the latest CombineCloudKit version compatible with your version requirement:

```bash
carthage update CombineCloudKit --use-xcframeworks
```

## 🌤 Using CombineCloudKit in Your Project

Combine allows you to chain value processing [Publishers](https://developer.apple.com/documentation/combine/publisher)
for one or more [Subscribers](https://developer.apple.com/documentation/combine/subscriber). Here, we perform a query on
our [`CKDatabase`](https://developer.apple.com/documentation/cloudkit/ckdatabase), then process the results
asynchronously. As each [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord) is read from the
database, it is passed to the [`map`](<https://developer.apple.com/documentation/combine/publishers/merge/map(_:)-6v8fv>)
publisher which publishes the value of the record's name field. Any errors in the chain so far can be handled in the
catch publisher, which passes [`CKRecordValue`](https://developer.apple.com/documentation/cloudkit/ckrecordvalue) values
along to our [`sink`](<https://developer.apple.com/documentation/combine/fail/sink(receivevalue:)>) subscriber where the
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

### Queueing and Cancellation

Just creating a `Publisher` does not queue a CloudKit operation. An operation is queued only once a `Subscriber`
subscribes to the `Publisher` and indicates
[`Demand`](https://developer.apple.com/documentation/combine/subscribers/demand).

Note that the [`Cancellable`](https://developer.apple.com/documentation/combine/cancellable) subscriber from
[`sink`](<https://developer.apple.com/documentation/combine/fail/sink(receivevalue:)>) will cancel the upstream publishers
when it is deinitialized. Take care to ensure that your subscribers live long enough to process values. If a
CombineCloudKit publisher is cancelled before it is finished emitting values, the underlying
[`CKOperation`](https://developer.apple.com/documentation/cloudkit/ckoperation) will be cancelled. This may be desirable
when performing a query and processing only the first few results. However, failing to wait for completion of a `save`,
`delete`, or `modify` operation may result in undesirable cancellation.

Note that because the `atBackgroundPriority` publishers are built on `CKDatabase` methods that do not provide means of
cancellation, they will not respond to requests for cancellation. If you need the publishers to respond to requests for
cooperative cancellation, please use the publishers that do not have `atBackgroundPriority` in their names. You can
still specify
[`QualityOfService.background`](https://developer.apple.com/documentation/foundation/qualityofservice/background)
by passing in a
[`CKOperation.Configuration`](https://developer.apple.com/documentation/cloudkit/ckoperation/configuration).

### Sharing Publishers among Multiple Subscribers

If two or more `Subscriber`s subscribe to the same CombineCloudKit `Publisher`, the operation will be queued twice.
This may be surprising if you're new to Combine! Queueing the same database operation twice could be inefficient or
potentially harmful. If you need to subscribe to a `Publisher` twice, use the
[`share`](<https://developer.apple.com/documentation/combine/publisher/share()>) and
[`makeConnectable`](<https://developer.apple.com/documentation/combine/publisher/makeconnectable()>)
operators. This will ensure the operation is queued only once.

I considered making the `Publisher`s all conform to
[`ConnectablePublisher`](https://developer.apple.com/documentation/combine/connectablepublisher)
by default, but that would require all callers to call
[`connect`](<https://developer.apple.com/documentation/combine/connectablepublisher/connect()>)
explicitly or to use the
[`autoconnect`](<https://developer.apple.com/documentation/combine/connectablepublisher/autoconnect()>)
operator, even if they did not intend to share the `Publisher`.

For more on this topic, please review:

- [Controlling Publishing with Connectable Publishers](https://developer.apple.com/documentation/combine/controlling-publishing-with-connectable-publishers)

## 📘 Documentation

💯% [documented](https://combinecloudkit.hiddenplace.dev) using [Jazzy](https://github.com/realm/jazzy).
Hosted by [GitHub Pages](https://pages.github.com).

## ❤️ Contributing

[Contributions](https://github.com/chris-araman/CombineCloudKit/blob/main/CONTRIBUTING.md) are welcome!

## 📚 Further Reading

To learn more about Combine and CloudKit, watch these videos from WWDC:

- [Introducing Combine](https://developer.apple.com/videos/play/wwdc2019/722)
- [Combine in Practice](https://developer.apple.com/videos/play/wwdc2019/721)

...or review Apple's documentation:

- [CloudKit Overview](https://developer.apple.com/icloud/cloudkit/)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [Combine Documentation](https://developer.apple.com/documentation/combine)

If you're looking for Swift concurrency extensions for CloudKit using `async`, `await`,
and `AsyncSequence`, take a look at [AsyncCloudKit](https://github.com/chris-araman/AsyncCloudKit)!

## 📜 License

CombineCloudKit was created by [Chris Araman](https://github.com/chris-araman). It is published under the
[MIT license](https://github.com/chris-araman/CombineCloudKit/blob/main/LICENSE.md).
