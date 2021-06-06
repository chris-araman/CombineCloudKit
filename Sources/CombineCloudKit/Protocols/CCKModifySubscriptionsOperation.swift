//
//  CCKModifySubscriptionsOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKModifySubscriptionsOperation: CCKModifySubscriptionsOperation {
}

protocol CCKModifySubscriptionsOperation: CCKDatabaseOperation {
  var modifySubscriptionsCompletionBlock:
    (([CKSubscription]?, [CKSubscription.ID]?, Error?) -> Void)?
  { get set }
}
