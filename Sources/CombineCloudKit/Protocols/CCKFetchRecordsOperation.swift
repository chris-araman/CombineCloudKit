//
//  CCKFetchRecordsOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKFetchRecordsOperation: CCKFetchRecordsOperation {
}

protocol CCKFetchRecordsOperation: CCKDatabaseOperation {
  var desiredKeys: [CKRecord.FieldKey]? { get set }
  var perRecordProgressBlock: ((CKRecord.ID, Double) -> Void)? { get set }
  var perRecordCompletionBlock: ((CKRecord?, CKRecord.ID?, Error?) -> Void)? { get set }
  var fetchRecordsCompletionBlock: (([CKRecord.ID: CKRecord]?, Error?) -> Void)? { get set }
}
