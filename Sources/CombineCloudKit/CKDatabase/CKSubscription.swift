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
  public final func saveAtBackgroundPriority(
    subscription: CKSubscription
  ) -> AnyPublisher<CKSubscription, Error> {
    publisherFrom(save, subscription)
  }

  public final func save(
    subscription: CKSubscription,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    save(subscriptions: [subscription], withConfiguration: configuration)
  }

  public final func save(
    subscriptions: [CKSubscription],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    let subject = PassthroughSubject<CKSubscription, Error>()
    let operation = CKModifySubscriptionsOperation(
      subscriptionsToSave: subscriptions,
      subscriptionIDsToDelete: nil
    )
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.modifySubscriptionsCompletionBlock = { subscriptions, _, error in
      guard let subscriptions = subscriptions, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for subscription in subscriptions {
        subject.send(subscription)
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
  }

  public final func deleteAtBackgroundPriority(
    subscriptionID: CKSubscription.ID
  ) -> AnyPublisher<CKSubscription.ID, Error> {
    publisherFrom(delete, subscriptionID)
  }

  public final func delete(
    subscriptionID: CKSubscription.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription.ID, Error> {
    delete(subscriptionIDs: [subscriptionID], withConfiguration: configuration)
  }

  public final func delete(
    subscriptionIDs: [CKSubscription.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription.ID, Error> {
    let subject = PassthroughSubject<CKSubscription.ID, Error>()
    let operation = CKModifySubscriptionsOperation(
      subscriptionsToSave: nil,
      subscriptionIDsToDelete: subscriptionIDs
    )
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.modifySubscriptionsCompletionBlock = { _, subscriptionIDs, error in
      guard let subscriptionIDs = subscriptionIDs, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for subscriptionID in subscriptionIDs {
        subject.send(subscriptionID)
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
  }

  public struct CCKModifySubscriptionPublishers {
    let saved: AnyPublisher<CKSubscription, Error>
    let deleted: AnyPublisher<CKSubscription.ID, Error>
  }

  public final func modify(
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

    add(operation)

    return CCKModifySubscriptionPublishers(
      saved: savedSubject.propagateCancellationTo(operation),
      deleted: deletedSubject.propagateCancellationTo(operation)
    )
  }

  public final func fetchAtBackgroundPriority(
    withSubscriptionID subscriptionID: CKSubscription.ID
  ) -> AnyPublisher<CKSubscription, Error> {
    publisherFrom(fetch, subscriptionID)
  }

  public final func fetch(
    subscriptionID: CKSubscription.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    fetch(subscriptionIDs: [subscriptionID], withConfiguration: configuration)
  }

  public final func fetch(
    subscriptionIDs: [CKSubscription.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    let subject = PassthroughSubject<CKSubscription, Error>()
    let operation = CKFetchSubscriptionsOperation(subscriptionIDs: subscriptionIDs)
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.fetchSubscriptionCompletionBlock = { subscriptions, error in
      guard let subscriptions = subscriptions, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for subscription in subscriptions.values {
        subject.send(subscription)
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
  }

  public final func fetchAllSubscriptionsAtBackgroundPriority()
    -> AnyPublisher<CKSubscription, Error>
  {
    let subject = PassthroughSubject<CKSubscription, Error>()

    fetchAllSubscriptions { subscriptions, error in
      guard let subscriptions = subscriptions, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for subscription in subscriptions {
        subject.send(subscription)
      }

      subject.send(completion: .finished)
    }

    return subject.eraseToAnyPublisher()
  }

  public final func fetchAllSubscriptions(
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    let subject = PassthroughSubject<CKSubscription, Error>()
    let operation = CKFetchSubscriptionsOperation.fetchAllSubscriptionsOperation()
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.fetchSubscriptionCompletionBlock = { subscriptions, error in
      guard let subscriptions = subscriptions, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for subscription in subscriptions.values {
        subject.send(subscription)
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
  }
}
