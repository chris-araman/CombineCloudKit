//
//  CCKDatabase.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/16/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

/// An extension that declares [`CKDatabase`](https://developer.apple.com/documentation/cloudkit/ckdatabase)
/// conforms to the ``CCKDatabase`` protocol provided by CombineCloudKit.
///
/// - SeeAlso: [`CloudKit`](https://developer.apple.com/documentation/cloudkit)
/// - SeeAlso: [`Combine`](https://developer.apple.com/documentation/combine)
extension CKDatabase: CCKDatabase {
}

/// A protocol used to abstract a [`CKDatabase`](https://developer.apple.com/documentation/cloudkit/ckdatabase).
///
/// Invoke the extension methods on your
/// [`CKDatabase`](https://developer.apple.com/documentation/cloudkit/ckdatabase)
/// instances in order to create [`Publishers`](https://developer.apple.com/documentation/combine/publishers).
///
/// - SeeAlso: [`CloudKit`](https://developer.apple.com/documentation/cloudkit)
/// - SeeAlso: [`Combine`](https://developer.apple.com/documentation/combine)
public protocol CCKDatabase {
  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449122-delete)
  func delete(
    withRecordID recordID: CKRecord.ID, completionHandler: @escaping (CKRecord.ID?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449118-delete)
  func delete(
    withRecordZoneID zoneID: CKRecordZone.ID,
    completionHandler: @escaping (CKRecordZone.ID?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/3003590-delete)
  func delete(
    withSubscriptionID subscriptionID: CKSubscription.ID,
    completionHandler: @escaping (String?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449126-fetch)
  func fetch(
    withRecordID recordID: CKRecord.ID, completionHandler: @escaping (CKRecord?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449104-fetch)
  func fetch(
    withRecordZoneID zoneID: CKRecordZone.ID,
    completionHandler: @escaping (CKRecordZone?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/3003591-fetch)
  func fetch(
    withSubscriptionID subscriptionID: CKSubscription.ID,
    completionHandler: @escaping (CKSubscription?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [fetchAllRecordZones](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449112-fetchallrecordzones)
  func fetchAllRecordZones(completionHandler: @escaping ([CKRecordZone]?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [fetchAllSubscriptions](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449110-fetchallsubscriptions)
  func fetchAllSubscriptions(completionHandler: @escaping ([CKSubscription]?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [fetchAllSubscriptions](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449127-perform)
  func perform(
    _ query: CKQuery,
    inZoneWith zoneID: CKRecordZone.ID?,
    completionHandler: @escaping ([CKRecord]?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449114-save)
  func save(_ record: CKRecord, completionHandler: @escaping (CKRecord?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449108-save)
  func save(_ zone: CKRecordZone, completionHandler: @escaping (CKRecordZone?, Error?) -> Void)

  /// Implemented by `CKDatabase`.
  ///
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449102-save)
  func save(
    _ subscription: CKSubscription, completionHandler: @escaping (CKSubscription?, Error?) -> Void)
}

extension CCKDatabase {
  func add(_ operation: CCKDatabaseOperation) {
    guard let database = self as? CKDatabase, let dbOperation = operation as? CKDatabaseOperation
    else {
      // TODO: Use an OperationQueue.
      operation.start()
      return
    }

    database.add(dbOperation)
  }

  func publisherAtBackgroundPriorityFrom<Input, Output>(
    _ method: @escaping (Input, @escaping (Output?, Error?) -> Void) -> Void,
    with input: Input
  ) -> AnyPublisher<Output, Error> {
    Deferred {
      Future { promise in
        DispatchQueue.main.async {
          method(input) { output, error in
            guard let output = output, error == nil else {
              promise(.failure(error!))
              return
            }

            promise(.success(output))
          }
        }
      }
    }.eraseToAnyPublisher()
  }

  func publisherFromFetch<Output, Ignored>(
    _ operation: CCKDatabaseOperation,
    _ configuration: CKOperation.Configuration? = nil,
    _ setCompletion: (@escaping ([Ignored: Output]?, Error?) -> Void) -> Void
  ) -> AnyPublisher<Output, Error> {
    let subject = PassthroughSubject<Output, Error>()
    if configuration != nil {
      operation.configuration = configuration
    }
    setCompletion { outputs, error in
      guard let outputs = outputs, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for output in outputs.values {
        subject.send(output)
      }

      subject.send(completion: .finished)
    }

    return Deferred { () -> PassthroughSubject<Output, Error> in
      DispatchQueue.main.async {
        self.add(operation)
      }

      return subject
    }.propagateCancellationTo(operation)
  }

  func publisherFromFetchAll<Output>(
    _ method: @escaping (@escaping ([Output]?, Error?) -> Void) -> Void
  ) -> AnyPublisher<Output, Error> {
    Deferred { () -> PassthroughSubject<Output, Error> in
      let subject = PassthroughSubject<Output, Error>()

      DispatchQueue.main.async {
        method { outputs, error in
          guard let outputs = outputs, error == nil else {
            subject.send(completion: .failure(error!))
            return
          }

          for output in outputs {
            subject.send(output)
          }

          subject.send(completion: .finished)
        }
      }

      return subject
    }.eraseToAnyPublisher()
  }

  func publisherFromModify<Output, OutputID>(
    _ operation: CCKDatabaseOperation,
    _ configuration: CKOperation.Configuration? = nil,
    _ setCompletion: (@escaping ([Output]?, [OutputID]?, Error?) -> Void) -> Void
  ) -> AnyPublisher<(Output?, OutputID?), Error> {
    let subject = PassthroughSubject<(Output?, OutputID?), Error>()
    if configuration != nil {
      operation.configuration = configuration
    }
    setCompletion { saved, deleted, error in
      guard error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      if let saved = saved {
        for output in saved {
          subject.send((output, nil))
        }
      }

      if let deleted = deleted {
        for outputID in deleted {
          subject.send((nil, outputID))
        }
      }

      subject.send(completion: .finished)
    }

    return Deferred { () -> PassthroughSubject<(Output?, OutputID?), Error> in
      DispatchQueue.main.async {
        self.add(operation)
      }

      return subject
    }.propagateCancellationTo(operation)
  }
}
