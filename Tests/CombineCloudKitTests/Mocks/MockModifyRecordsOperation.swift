//
//  MockModifyRecordsOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import CombineCloudKit

public class MockModifyRecordsOperation:
  MockModifyOperation<CKRecord, CKRecord.ID>,
  CCKModifyRecordsOperation
{
  init(
    _ database: MockDatabase,
    _ space: DecisionSpace?,
    _ recordsToSave: [CKRecord]? = nil,
    _ recordIDsToDelete: [CKRecord.ID]? = nil
  ) {
    super.init(
      database,
      space,
      { mockDatabase, operation in operation(&mockDatabase.records) },
      \.recordID,
      recordsToSave,
      recordIDsToDelete
    )
    super.perItemCompletionBlock = { [unowned self] record, error in
      if let perRecordProgressBlock = self.perRecordProgressBlock, error == nil {
        perRecordProgressBlock(record, 0.7)
        perRecordProgressBlock(record, 1.0)
      }

      if let perRecordCompletionBlock = self.perRecordCompletionBlock {
        perRecordCompletionBlock(record, error)
      }
    }
    super.modifyItemsCompletionBlock = { [unowned self] itemsToSave, itemIDsToDelete, error in
      let completion = try! XCTUnwrap(self.modifyRecordsCompletionBlock)
      completion(itemsToSave, itemIDsToDelete, error)
    }
  }

  public var isAtomic = true

  public var perRecordProgressBlock: ((CKRecord, Double) -> Void)?

  public var perRecordCompletionBlock: ((CKRecord, Error?) -> Void)?

  public var modifyRecordsCompletionBlock: (([CKRecord]?, [CKRecord.ID]?, Error?) -> Void)?
}
