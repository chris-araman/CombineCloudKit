//
//  CKSubscription.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/16/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension CKDatabase {
  public func saveAtBackgroundPriority(
    subscription: CKSubscription
  ) -> Future<CKSubscription, Error> {
    Future { promise in
      self.save(subscription) { subscription, error in
        guard let subscription = subscription, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(subscription))
      }
    }
  }

  public func save(
    subscription: CKSubscription,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    let operation = CKModifySubscriptionsOperation(
      subscriptionsToSave: [subscription],
      subscriptionIDsToDelete: nil
    )
    if configuration != nil {
      operation.configuration = configuration
    }

    return Future { promise in
      operation.modifySubscriptionsCompletionBlock = { subscriptions, _, error in
        guard let subscription = subscriptions?.first, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(subscription))
      }

      self.add(operation)
    }.handleEvents(receiveCancel: {
      operation.cancel()
    }).eraseToAnyPublisher()
  }

  public func save(
    subscriptions: [CKSubscription],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<[CKSubscription], Error> {
    let operation = CKModifySubscriptionsOperation(
      subscriptionsToSave: subscriptions,
      subscriptionIDsToDelete: nil
    )
    if configuration != nil {
      operation.configuration = configuration
    }

    return Future { promise in
      operation.modifySubscriptionsCompletionBlock = { subscriptions, _, error in
        guard let subscriptions = subscriptions, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(subscriptions))
      }

      self.add(operation)
    }.handleEvents(receiveCancel: {
      operation.cancel()
    }).eraseToAnyPublisher()
  }

  public func deleteAtBackgroundPriority(
    subscriptionID: CKSubscription.ID
  ) -> Future<CKSubscription.ID, Error> {
    Future { promise in
      self.delete(withSubscriptionID: subscriptionID) { subscriptionID, error in
        guard let subscriptionID = subscriptionID, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(subscriptionID))
      }
    }
  }

  public func delete(
    subscriptionID: CKSubscription.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription.ID, Error> {
    let operation = CKModifySubscriptionsOperation(
      subscriptionsToSave: nil,
      subscriptionIDsToDelete: [subscriptionID]
    )
    if configuration != nil {
      operation.configuration = configuration
    }

    return Future { promise in
      operation.modifySubscriptionsCompletionBlock = { _, subscriptionIDs, error in
        guard let subscriptionID = subscriptionIDs?.first, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(subscriptionID))
      }

      self.add(operation)
    }.handleEvents(receiveCancel: {
      operation.cancel()
    }).eraseToAnyPublisher()
  }

  public func delete(
    subscriptionIDs: [CKSubscription.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<[CKSubscription.ID], Error> {
    let operation = CKModifySubscriptionsOperation(
      subscriptionsToSave: nil,
      subscriptionIDsToDelete: subscriptionIDs
    )
    if configuration != nil {
      operation.configuration = configuration
    }

    return Future { promise in
      operation.modifySubscriptionsCompletionBlock = { _, subscriptionIDs, error in
        guard let subscriptionIDs = subscriptionIDs, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(subscriptionIDs))
      }

      self.add(operation)
    }.handleEvents(receiveCancel: {
      operation.cancel()
    }).eraseToAnyPublisher()
  }
  
  public struct CCKModifySubscriptionPublishers {
    let saved: AnyPublisher<CKSubscription, Error>
    let deleted: AnyPublisher<CKSubscription.ID, Error>
  }

  public func modify(
    subscriptionsToSave: [CKSubscription]? = nil,
    subscriptionIDsToDelete: [CKSubscription.ID]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> CCKModifySubscriptionPublishers {
    let savedSubject = PassthroughSubject<CKSubscription, Error>()
    let deletedSubject = PassthroughSubject<CKSubscription.ID, Error>()
    let operation = CKModifySubscriptionsOperation(
      subscriptionsToSave: subscriptionsToSave,
      subscriptionIDsToDelete: subscriptionIDsToDelete
    )
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.modifySubscriptionsCompletionBlock = { saved, deleted, error in
      guard error == nil else {
        savedSubject.send(completion: .failure(error!))
        deletedSubject.send(completion: .failure(error!))
        return
      }
      
      if let saved = saved {
        for subscription in saved {
          savedSubject.send(subscription)
        }
      }

      if let deleted = deleted {
        for subscription in deleted {
          deletedSubject.send(subscription)
        }
      }

      savedSubject.send(completion: .finished)
      deletedSubject.send(completion: .finished)
    }

    self.add(operation)
    
    return CCKModifySubscriptionPublishers(
      saved: savedSubject.handleEvents(receiveCancel: { operation.cancel() }).eraseToAnyPublisher(),
      deleted: deletedSubject.handleEvents(receiveCancel: { operation.cancel() }).eraseToAnyPublisher()
    )
  }

  public func fetchAtBackgroundPriority(
    withSubscriptionID subscriptionID: CKSubscription.ID
  ) -> Future<CKSubscription, Error> {
    Future { promise in
      self.fetch(withSubscriptionID: subscriptionID) { subscription, error in
        guard let subscription = subscription, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(subscription))
      }
    }
  }

  public func fetch(
    withSubscriptionID subscriptionID: CKSubscription.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    let operation = CKFetchSubscriptionsOperation(subscriptionIDs: [subscriptionID])
    if configuration != nil {
      operation.configuration = configuration
    }

    return Future { promise in
      operation.fetchSubscriptionCompletionBlock = { subsciptions, error in
        guard let subsciption = subsciptions?.first?.value, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(subsciption))
      }

      self.add(operation)
    }.handleEvents(receiveCancel: {
      operation.cancel()
    }).eraseToAnyPublisher()
  }

  public func fetch(
    subscriptionIDs: [CKSubscription.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<[CKSubscription.ID: CKSubscription], Error> {
    let operation = CKFetchSubscriptionsOperation(subscriptionIDs: subscriptionIDs)
    if configuration != nil {
      operation.configuration = configuration
    }

    return Future { promise in
      operation.fetchSubscriptionCompletionBlock = { subscriptions, error in
        guard let subscriptions = subscriptions, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(subscriptions))
      }

      self.add(operation)
    }.handleEvents(receiveCancel: {
      operation.cancel()
    }).eraseToAnyPublisher()
  }

  public func fetchAllSubscriptionsAtBackgroundPriority()
    -> Future<[CKSubscription.ID: CKSubscription], Error>
  {
    Future { promise in
      self.fetchAllSubscriptions { subscriptions, error in
        guard let subscriptions = subscriptions, error == nil else {
          promise(.failure(error!))
          return
        }

        var idsToSubscriptions = [CKSubscription.ID: CKSubscription]()
        idsToSubscriptions.reserveCapacity(subscriptions.count)
        for subscription in subscriptions {
          idsToSubscriptions[subscription.subscriptionID] = subscription
        }

        promise(.success(idsToSubscriptions))
      }
    }
  }

  public func fetchAllSubscriptions(
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<[CKSubscription.ID: CKSubscription], Error> {
    let operation = CKFetchSubscriptionsOperation.fetchAllSubscriptionsOperation()
    if configuration != nil {
      operation.configuration = configuration
    }

    return Future { promise in
      operation.fetchSubscriptionCompletionBlock = { subscriptions, error in
        guard let subscriptions = subscriptions, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(subscriptions))
      }

      self.add(operation)
    }.handleEvents(receiveCancel: {
      operation.cancel()
    }).eraseToAnyPublisher()
  }
}
