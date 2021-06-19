//
//  QueryPublisher.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/28/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

/// A custom `Publisher` that emits `CKRecord` values from `CKQueryOperation`.
internal class QueryPublisher: Publisher {
  typealias Output = CKRecord
  typealias Failure = Error

  private let database: CCKDatabase
  private let query: CKQuery
  private let zoneID: CKRecordZone.ID?
  private let desiredKeys: [CKRecord.FieldKey]?
  private let configuration: CKOperation.Configuration?

  internal init(
    database: CCKDatabase,
    _ query: CKQuery,
    _ zoneID: CKRecordZone.ID?,
    _ desiredKeys: [CKRecord.FieldKey]?,
    _ configuration: CKOperation.Configuration?
  ) {
    self.database = database
    self.query = query
    self.zoneID = zoneID
    self.desiredKeys = desiredKeys
    self.configuration = configuration
  }

  func receive<Downstream>(subscriber: Downstream)
  where Downstream: Subscriber, Downstream.Input == Output, Downstream.Failure == Failure {
    subscriber.receive(subscription: QuerySubscription(self, subscriber))
  }

  /// A `Subscription` that responds to back pressure and starts a new `CKQueryOperation` whenever demand and additional
  /// records remain.
  ///
  /// When the `QuerySubscription` is cancelled, the underlying `CKQueryOperation` is cancelled.
  private class QuerySubscription<Downstream>: Subscription
  where Downstream: Subscriber, Downstream.Input == Output, Downstream.Failure == Failure {
    private let publisher: QueryPublisher
    private let queue: DispatchQueue
    private var subscriber: Downstream?
    private var demand = Subscribers.Demand.none
    private var operation: CCKQueryOperation
    private var operationIsQueued = false

    internal init(_ publisher: QueryPublisher, _ subscriber: Downstream) {
      self.publisher = publisher
      self.subscriber = subscriber
      queue = DispatchQueue(label: String(describing: type(of: self)))
      operation = operationFactory.createQueryOperation()
      operation.query = publisher.query
      prepareOperation()
    }

    func request(_ demand: Subscribers.Demand) {
      if demand == Subscribers.Demand.none {
        return
      }

      queue.async {
        guard self.subscriber != nil else {
          return
        }

        self.demand += demand

        if !self.operationIsQueued {
          self.operation.resultsLimit = self.demand.max ?? CKQueryOperation.maximumResults
          self.publisher.database.add(self.operation)
          self.operationIsQueued = true
        }
      }
    }

    func cancel() {
      subscriber = nil
      operation.cancel()
    }

    private func prepareOperation() {
      operation.desiredKeys = publisher.desiredKeys
      operation.zoneID = publisher.zoneID
      operation.resultsLimit = demand.max ?? CKQueryOperation.maximumResults

      if publisher.configuration != nil {
        operation.configuration = publisher.configuration
      }

      operation.recordFetchedBlock = { [weak self] record in
        guard let publisher = self else {
          return
        }

        publisher.queue.async {
          assert(publisher.demand != Subscribers.Demand.none)

          guard let subscriber = publisher.subscriber else {
            // Ignore any remaining results.
            return
          }

          publisher.demand -= 1
          publisher.demand += subscriber.receive(record)
        }
      }

      operation.queryCompletionBlock = { [weak self] cursor, error in
        guard let publisher = self else {
          return
        }

        publisher.queue.async {
          guard let subscriber = publisher.subscriber else {
            return
          }

          guard error == nil else {
            subscriber.receive(completion: .failure(error!))
            publisher.subscriber = nil
            return
          }

          guard let cursor = cursor else {
            // We've fetched all the results.
            subscriber.receive(completion: .finished)
            publisher.subscriber = nil
            return
          }

          // Prepare to fetch the next page of results.
          publisher.operation = operationFactory.createQueryOperation()
          publisher.operation.cursor = cursor
          publisher.prepareOperation()
          if publisher.demand == Subscribers.Demand.none {
            publisher.operationIsQueued = false
          } else {
            publisher.publisher.database.add(publisher.operation)
            publisher.operationIsQueued = true
          }
        }
      }
    }
  }
}
