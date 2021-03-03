# CombineCloudKit

Swift Combine extensions for asynchronous CloudKit record processing. Designed for simplicity.

CombineCloudKit exposes [CloudKit](https://developer.apple.com/documentation/cloudkit) operations as
[Combine](https://developer.apple.com/documentation/combine) publishers. Publishers can be used to process values over
time, using Combine's declarative API.

## Usage

CombineCloudKit is a [Swift Package](https://developer.apple.com/documentation/swift_packages). Add a dependency on
CombineCloudKit to your project using
[Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) or the
[Swift Package Manager](https://swift.org/package-manager/).

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
