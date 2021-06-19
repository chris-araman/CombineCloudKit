//
//  CCKDatabase+CKSubscription.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/16/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension CCKDatabase {
  /// Saves a single subscription.
  ///
  /// - Parameters:
  ///   - subscription: The subscription to save.
  /// - Note: CombineCloudKit executes the save with a low priority. Use this method when you don’t require the save to
  /// happen immediately.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the saved
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription), or an error if CombineCloudKit can't save it.
  /// The publisher ignores requests for cooperative cancellation.
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449102-save)
  public func saveAtBackgroundPriority(
    subscription: CKSubscription
  ) -> AnyPublisher<CKSubscription, Error> {
    publisherAtBackgroundPriorityFrom(save, with: subscription)
  }

  /// Saves a single subscription.
  ///
  /// - Parameters:
  ///   - subscription: The subscription to save.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the saved
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription), or an error if CombineCloudKit can't save it.
  /// - SeeAlso: [`CKModifySubscriptionsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifysubscriptionsoperation)
  public func save(
    subscription: CKSubscription,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    save(subscriptions: [subscription], withConfiguration: configuration)
  }

  /// Saves multiple subscriptions.
  ///
  /// - Parameters:
  ///   - subscriptions: The subscriptions to save.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the saved
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription)s, or an error if CombineCloudKit can't save them.
  /// - SeeAlso: [`CKModifySubscriptionsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifysubscriptionsoperation)
  public func save(
    subscriptions: [CKSubscription],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    modify(subscriptionsToSave: subscriptions, withConfiguration: configuration).compactMap {
      saved, _ in
      saved
    }.eraseToAnyPublisher()
  }

  /// Deletes a single subscription.
  ///
  /// - Parameters:
  ///   - subscriptionID: The ID of the subscription to delete.
  /// - Note: CombineCloudKit executes the delete with a low priority. Use this method when you don’t require the delete
  /// to happen immediately.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the deleted
  /// [`CKSubscription.ID`](https://developer.apple.com/documentation/cloudkit/cksubscription/id), or an error if CombineCloudKit can't delete it.
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/3003590-delete)
  public func deleteAtBackgroundPriority(
    subscriptionID: CKSubscription.ID
  ) -> AnyPublisher<CKSubscription.ID, Error> {
    publisherAtBackgroundPriorityFrom(delete, with: subscriptionID)
  }

  /// Deletes a single subscription.
  ///
  /// - Parameters:
  ///   - subscriptionID: The ID of the subscription to delete.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the deleted
  /// [`CKSubscription.ID`](https://developer.apple.com/documentation/cloudkit/cksubscription/id), or an error if CombineCloudKit can't delete
  /// it.
  /// - SeeAlso: [`CKModifySubscriptionsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifysubscriptionsoperation)
  public func delete(
    subscriptionID: CKSubscription.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription.ID, Error> {
    delete(subscriptionIDs: [subscriptionID], withConfiguration: configuration)
  }

  /// Deletes multiple subscriptions.
  ///
  /// - Parameters:
  ///   - subscriptionIDs: The IDs of the subscriptions to delete.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the deleted
  /// [`CKSubscription.ID`](https://developer.apple.com/documentation/cloudkit/cksubscription/id)s, or an error if CombineCloudKit can't delete
  /// them.
  /// - SeeAlso: [`CKModifySubscriptionsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifysubscriptionsoperation)
  public func delete(
    subscriptionIDs: [CKSubscription.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription.ID, Error> {
    modify(subscriptionIDsToDelete: subscriptionIDs, withConfiguration: configuration).compactMap {
      _, deleted in
      deleted
    }.eraseToAnyPublisher()
  }

  /// Modifies one or more subscriptions.
  ///
  /// - Parameters:
  ///   - subscriptionsToSave: The subscriptions to save.
  ///   - subscriptionsToDelete: The IDs of the subscriptions to delete.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the saved
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription)s and the deleted
  /// [`CKSubscription.ID`](https://developer.apple.com/documentation/cloudkit/cksubscription/id)s, or an
  ///   error if CombineCloudKit can't modify them.
  /// - SeeAlso: [`CKModifySubscriptionsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifysubscriptionsoperation)
  public func modify(
    subscriptionsToSave: [CKSubscription]? = nil,
    subscriptionIDsToDelete: [CKSubscription.ID]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<(CKSubscription?, CKSubscription.ID?), Error> {
    let operation = operationFactory.createModifySubscriptionsOperation(
      subscriptionsToSave: subscriptionsToSave,
      subscriptionIDsToDelete: subscriptionIDsToDelete
    )
    return publisherFromModify(operation, configuration) { completion in
      operation.modifySubscriptionsCompletionBlock = completion
    }
  }

  /// Fetches the subscription with the specified ID.
  ///
  /// - Parameters:
  ///   - subscriptionID: The ID of the subscription to fetch.
  /// - Note: CombineCloudKit executes the fetch with a low priority. Use this method when you don’t require the
  /// subscription immediately.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription), or an error if CombineCloudKit can't fetch it.
  /// The publisher ignores requests for cooperative cancellation.
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/3003591-fetch)
  public func fetchAtBackgroundPriority(
    withSubscriptionID subscriptionID: CKSubscription.ID
  ) -> AnyPublisher<CKSubscription, Error> {
    publisherAtBackgroundPriorityFrom(fetch, with: subscriptionID)
  }

  /// Fetches the subscription with the specified ID.
  ///
  /// - Parameters:
  ///   - subscriptionID: The ID of the subscription to fetch.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription), or an error if CombineCloudKit can't fetch it.
  /// - SeeAlso: [CKFetchSubscriptionsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchsubscriptionsoperation)
  public func fetch(
    subscriptionID: CKSubscription.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    fetch(subscriptionIDs: [subscriptionID], withConfiguration: configuration)
  }

  /// Fetches multiple subscriptions.
  ///
  /// - Parameters:
  ///   - subscriptionIDs: The IDs of the subscriptions to fetch.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription)s, or an error if CombineCloudKit can't fetch them.
  /// - SeeAlso: [CKFetchSubscriptionsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchsubscriptionsoperation)
  public func fetch(
    subscriptionIDs: [CKSubscription.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    let operation = operationFactory.createFetchSubscriptionsOperation(
      subscriptionIDs: subscriptionIDs)
    return publisherFromFetch(operation, configuration) { completion in
      operation.fetchSubscriptionCompletionBlock = completion
    }
  }

  /// Fetches the database's subscriptions.
  ///
  /// - Note: CombineCloudKit executes the fetch with a low priority. Use this method when you don’t require the
  /// subscriptions immediately.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription)s, or an error if CombineCloudKit can't fetch them.
  /// The publisher ignores requests for cooperative cancellation.
  /// - SeeAlso: [fetchAllSubscriptions](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449110-fetchallsubscriptions)
  public func fetchAllSubscriptionsAtBackgroundPriority()
    -> AnyPublisher<CKSubscription, Error>
  {
    publisherFromFetchAll(fetchAllSubscriptions)
  }

  /// Fetches the database's subscriptions.
  ///
  /// - Parameters:
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the
  /// [`CKSubscription`](https://developer.apple.com/documentation/cloudkit/cksubscription)s, or an error if CombineCloudKit can't fetch them.
  /// - SeeAlso:
  /// [fetchAllSubscriptionsOperation]
  /// (https://developer.apple.com/documentation/cloudkit/ckfetchsubscriptionsoperation/1515282-fetchallsubscriptionsoperation)
  public func fetchAllSubscriptions(
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKSubscription, Error> {
    let operation = operationFactory.createFetchAllSubscriptionsOperation()
    return publisherFromFetch(operation, configuration) { completion in
      operation.fetchSubscriptionCompletionBlock = completion
    }
  }
}
