//
//  CCKModifyRecordZonesOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKModifyRecordZonesOperation: CCKModifyRecordZonesOperation {
}

protocol CCKModifyRecordZonesOperation: CCKDatabaseOperation {
  var modifyRecordZonesCompletionBlock: (([CKRecordZone]?, [CKRecordZone.ID]?, Error?) -> Void)? {
    get set
  }
}
