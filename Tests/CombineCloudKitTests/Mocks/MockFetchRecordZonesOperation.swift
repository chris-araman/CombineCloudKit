//
//  MockFetchRecordZonesOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import CombineCloudKit

public class MockFetchRecordZonesOperation: MockFetchOperation<CKRecordZone, CKRecordZone.ID>,
  CCKFetchRecordZonesOperation
{
  init(
    _ database: MockDatabase,
    _ space: DecisionSpace?,
    _ recordZoneIDs: [CKRecordZone.ID]? = nil
  ) {
    super.init(
      database,
      space,
      { database, operation in operation(&database.recordZones) },
      recordZoneIDs
    )
    super.fetchItemsCompletionBlock = { [unowned self] items, error in
      let completion = try! XCTUnwrap(self.fetchRecordZonesCompletionBlock)
      completion(items, error)
    }
  }

  public var fetchRecordZonesCompletionBlock: (([CKRecordZone.ID: CKRecordZone]?, Error?) -> Void)?
}
