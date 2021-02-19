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
    publisherFrom(method: save, with: subscription)
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
    let operation = CKModifySubscriptionsOperation(
      subscriptionsToSave: subscriptions,
      subscriptionIDsToDelete: nil)
    return publisherFromOperation(
      operation,
      withConfiguration: configuration) { completion in
      operation.modifySubscriptionsCompletionBlock = completion
    }
  }

  public final func deleteAtBackgroundPriority(
    subscriptionID: CKSubscription.ID
  ) -> AnyPublisher<CKSubscription.ID, Error> {
    publisherFrom(method: delete, with: subscriptionID)
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
    let operation = CKModifySubscriptionsOperation(
      subscriptionsToSave: nil,
      subscriptionIDsToDelete: subscriptionIDs
    )
    return publisherFromOperation(
      operation,
      withConfiguration: configuration) { completion in
      operation.modifySubscriptionsCompletionBlock = completion
    }
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
    publisherFrom(method: fetch, with: subscriptionID)
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
    let operation = CKFetchSubscriptionsOperation(subscriptionIDs: subscriptionIDs)
    return publisherFromOperation(
      operation,
      withConfiguration: configuration) { completion in
      operation.fetchSubscriptionCompletionBlock = completion
    }
  }

  public final func fetchAllSubscriptionsAtBackgroundPriority()
    -> AnyPublisher<CKSubscription, Error>
  {
    publisherFrom(method: fetchAllSubscriptions)
  }

  public final func fetchAllSubscriptions(
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    let operation = CKFetchSubscriptionsOperation.fetchAllSubscriptionsOperation()
    return publisherFromOperation(
      operation,
      withConfiguration: configuration) { completion in
      operation.fetchSubscriptionCompletionBlock = completion
    }
  }
}
