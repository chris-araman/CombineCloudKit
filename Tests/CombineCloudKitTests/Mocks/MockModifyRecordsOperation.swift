//
//  MockModifyRecordsOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import CombineCloudKit

public class MockModifyRecordsOperation:
  MockModifyOperation<CKRecord, CKRecord.ID>,
  CCKModifyRecordsOperation
{
  init(
    _ database: MockDatabase,
    _ recordsToSave: [CKRecord]? = nil,
    _ recordIDsToDelete: [CKRecord.ID]? = nil
  ) {
    super.init(
      database,
      { mockDatabase, operation in operation(&mockDatabase.records) },
      \.recordID,
      recordsToSave,
      recordIDsToDelete
    )
    super.perItemCompletionBlock = { record, error in
      // TODO: Simulate progress before error.
      if let perRecordProgressBlock = self.perRecordProgressBlock, error == nil {
        perRecordProgressBlock(record, 0.7)
        perRecordProgressBlock(record, 1.0)
      }

      if let perRecordCompletionBlock = self.perRecordCompletionBlock {
        perRecordCompletionBlock(record, error)
      }
    }
    super.modifyItemsCompletionBlock = { itemsToSave, itemIDsToDelete, error in
      guard let completion = self.modifyRecordsCompletionBlock else {
        // TODO: XCTFail
        fatalError("modifyRecordsCompletionBlock not set.")
      }

      completion(itemsToSave, itemIDsToDelete, error)
    }
  }

  public var isAtomic = true

  public var perRecordProgressBlock: ((CKRecord, Double) -> Void)?

  public var perRecordCompletionBlock: ((CKRecord, Error?) -> Void)?

  public var modifyRecordsCompletionBlock: (([CKRecord]?, [CKRecord.ID]?, Error?) -> Void)?
}
