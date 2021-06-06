//
//  CCKFetchRecordZonesOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKFetchRecordZonesOperation: CCKFetchRecordZonesOperation {
}

protocol CCKFetchRecordZonesOperation: CCKDatabaseOperation {
  var fetchRecordZonesCompletionBlock: (([CKRecordZone.ID: CKRecordZone]?, Error?) -> Void)? {
    get set
  }
}
