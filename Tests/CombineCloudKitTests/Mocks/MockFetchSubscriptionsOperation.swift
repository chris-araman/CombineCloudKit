//
//  MockFetchSubscriptionsOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import CombineCloudKit

public class MockFetchSubscriptionsOperation: MockFetchOperation<CKSubscription, CKSubscription.ID>,
  CCKFetchSubscriptionsOperation
{
  init(
    _ database: MockDatabase,
    _ space: DecisionSpace?,
    _ subscriptionIDs: [CKSubscription.ID]? = nil
  ) {
    super.init(
      database,
      space,
      { database, operation in operation(&database.subscriptions) },
      subscriptionIDs
    )
    super.fetchItemsCompletionBlock = { [unowned self] items, error in
      let completion = try! XCTUnwrap(self.fetchSubscriptionCompletionBlock)
      completion(items, error)
    }
  }

  public var fetchSubscriptionCompletionBlock:
    (([CKSubscription.ID: CKSubscription]?, Error?) -> Void)?
}
