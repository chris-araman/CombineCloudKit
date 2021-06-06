//
//  MockFetchSubscriptionsOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import CombineCloudKit

public class MockFetchSubscriptionsOperation: MockDatabaseOperation, CCKFetchSubscriptionsOperation
{
  let subscriptionIDs: [CKSubscription.ID]?

  init(_ database: MockDatabase, _ subscriptionIDs: [CKSubscription.ID]? = nil) {
    self.subscriptionIDs = subscriptionIDs
    super.init(database)
  }

  public var fetchSubscriptionCompletionBlock:
    (([CKSubscription.ID: CKSubscription]?, Error?) -> Void)?

  public override func start() {
    guard let completion = fetchSubscriptionCompletionBlock else {
      // TODO: XCTFail
      fatalError("fetchSubscriptionCompletionBlock not set.")
    }

    mockDatabase.queue.async {
      guard let subscriptionIDs = self.subscriptionIDs else {
        completion(self.mockDatabase.subscriptions, nil)
        return
      }

      guard subscriptionIDs.allSatisfy(self.mockDatabase.subscriptions.keys.contains) else {
        completion(nil, MockError.doesNotExist)
        return
      }

      let subscriptions = self.mockDatabase.subscriptions.filter { subscriptionID, _ in
        subscriptionIDs.contains(subscriptionID)
      }

      // TODO: Simulate failures.
      completion(subscriptions, nil)
    }
  }
}
