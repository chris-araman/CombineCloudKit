//
//  CCKFetchSubscriptionsOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKFetchSubscriptionsOperation: CCKFetchSubscriptionsOperation {
}

protocol CCKFetchSubscriptionsOperation: CCKDatabaseOperation {
  var fetchSubscriptionCompletionBlock: (([CKSubscription.ID: CKSubscription]?, Error?) -> Void)? {
    get set
  }
}
