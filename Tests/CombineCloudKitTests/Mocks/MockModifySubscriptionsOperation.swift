//
//  MockModifySubscriptionsOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

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
      \.subscriptionID,
      subscriptionsToSave,
      subscriptionIDsToDelete
    )
    super.modifyItemsCompletionBlock = { itemsToSave, itemIDsToDelete, error in
      let completion = try! XCTUnwrap(self.modifySubscriptionsCompletionBlock)
      completion(itemsToSave, itemIDsToDelete, error)
    }
  }
}
