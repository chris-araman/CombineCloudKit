//
//  CCKModifyRecordsOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKModifyRecordsOperation: CCKModifyRecordsOperation {
}

protocol CCKModifyRecordsOperation: CCKDatabaseOperation {
  var isAtomic: Bool { get set }
  var savePolicy: CKModifyRecordsOperation.RecordSavePolicy { get set }
  var clientChangeTokenData: Data? { get set }
  var perRecordProgressBlock: ((CKRecord, Double) -> Void)? { get set }
  var perRecordCompletionBlock: ((CKRecord, Error?) -> Void)? { get set }
  var modifyRecordsCompletionBlock: (([CKRecord]?, [CKRecord.ID]?, Error?) -> Void)? { get set }
}
