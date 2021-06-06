//
//  MockModifySubscriptionsOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import CombineCloudKit

public class MockModifySubscriptionsOperation:
  MockModifyOperation<CKSubscription, CKSubscription.ID>,
  CCKModifySubscriptionsOperation
{
  public var modifySubscriptionsCompletionBlock:
    (([CKSubscription]?, [CKSubscription.ID]?, Error?) -> Void)?

  init(
    _ database: MockDatabase,
    _ subscriptionsToSave: [CKSubscription]? = nil,
    _ subscriptionIDsToDelete: [CKSubscription.ID]? = nil
  ) {
    super.init(
      database,
      { mockDatabase, operation in operation(&mockDatabase.subscriptions) },
      { subscription in subscription.subscriptionID },
      subscriptionsToSave,
      subscriptionIDsToDelete
    )
    super.modifyItemsCompletionBlock = { itemsToSave, itemIDsToDelete, error in
      guard let completion = self.modifySubscriptionsCompletionBlock else {
        // TODO: XCTFail
        fatalError("modifySubscriptionsCompletionBlock not set.")
      }

      completion(itemsToSave, itemIDsToDelete, error)
    }
  }
}
