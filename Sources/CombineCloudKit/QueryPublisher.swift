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
    private let operationQueue: OperationQueue
    private let dispatchQueue: DispatchQueue
    private var subscriber: Downstream?
    private var demand = Subscribers.Demand.none
    private var operation: CKQueryOperation
    private var operationIsQueued = false

    internal init(_ publisher: QueryPublisher, _ subscriber: Downstream) {
      self.publisher = publisher
      self.subscriber = subscriber

      let qos: DispatchQoS
      switch publisher.configuration?.qualityOfService {
      case .userInteractive:
        qos = .userInteractive
      case .userInitiated:
        qos = .userInitiated
      case .utility:
        qos = .utility
      case .background:
        qos = .background
      default:
        qos = .default
      }

      dispatchQueue = DispatchQueue(label: String(describing: type(of: self)), qos: qos)

      operationQueue = OperationQueue()
      operationQueue.name = dispatchQueue.label
      operationQueue.underlyingQueue = dispatchQueue
      if let qos = publisher.configuration?.qualityOfService {
        operationQueue.qualityOfService = qos
      }

      operation = CKQueryOperation(query: publisher.query)
      prepareOperation()
    }

    func request(_ demand: Subscribers.Demand) {
      if demand == Subscribers.Demand.none {
        return
      }

      dispatchQueue.async {
        guard self.subscriber != nil else {
          return
        }

        self.demand += demand

        if !self.operationIsQueued {
          self.operationQueue.addOperation(self.operation)
          self.operationIsQueued = true
        }
      }
    }

    func cancel() {
      subscriber = nil
      operation.cancel()
    }

    private func prepareOperation() {
      operation.database = publisher.database as? CKDatabase
      operation.desiredKeys = publisher.desiredKeys
      operation.zoneID = publisher.zoneID
      operation.resultsLimit = demand.max ?? CKQueryOperation.maximumResults

      if publisher.configuration != nil {
        operation.configuration = publisher.configuration
      }

      operation.recordFetchedBlock = { record in
        assert(self.demand != Subscribers.Demand.none)

        guard let subscriber = self.subscriber else {
          // Ignore any remaining results.
          return
        }

        self.demand -= 1
        self.demand += subscriber.receive(record)
      }

      operation.queryCompletionBlock = { cursor, error in
        guard let subscriber = self.subscriber else {
          return
        }

        guard error == nil else {
          subscriber.receive(completion: .failure(error!))
          self.subscriber = nil
          return
        }

        guard let cursor = cursor else {
          // We've fetched all the results.
          subscriber.receive(completion: .finished)
          self.subscriber = nil
          return
        }

        // Prepare to fetch the next page of results.
        self.operation = CKQueryOperation(cursor: cursor)
        self.prepareOperation()
        if self.demand == Subscribers.Demand.none {
          self.operationIsQueued = false
        } else {
          self.operationQueue.addOperation(self.operation)
          self.operationIsQueued = true
        }
      }
    }
  }
}
