//
//  MockModifyRecordZonesOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import CombineCloudKit

public class MockModifyRecordZonesOperation:
  MockModifyOperation<CKRecordZone, CKRecordZone.ID>,
  CCKModifyRecordZonesOperation
{
  public var modifyRecordZonesCompletionBlock:
    (([CKRecordZone]?, [CKRecordZone.ID]?, Error?) -> Void)?

  init(
    _ database: MockDatabase,
    _ recordZonesToSave: [CKRecordZone]? = nil,
    _ recordZoneIDsToDelete: [CKRecordZone.ID]? = nil
  ) {
    super.init(
      database,
      { mockDatabase, operation in operation(&mockDatabase.recordZones) },
      \.zoneID,
      recordZonesToSave,
      recordZoneIDsToDelete
    )
    super.modifyItemsCompletionBlock = { itemsToSave, itemIDsToDelete, error in
      let completion = try! XCTUnwrap(self.modifyRecordZonesCompletionBlock)
      completion(itemsToSave, itemIDsToDelete, error)
    }
  }
}
