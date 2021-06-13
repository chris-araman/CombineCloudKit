//
//  MockFetchRecordZonesOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import CombineCloudKit

public class MockFetchRecordZonesOperation: MockFetchOperation<CKRecordZone, CKRecordZone.ID>,
  CCKFetchRecordZonesOperation
{
  init(_ database: MockDatabase, _ recordZoneIDs: [CKRecordZone.ID]? = nil) {
    super.init(
      database,
      { database, operation in operation(&database.recordZones) },
      recordZoneIDs
    )
    super.fetchItemsCompletionBlock = { items, error in
      guard let completion = self.fetchRecordZonesCompletionBlock else {
        // TODO: XCTFail
        fatalError("fetchRecordZonesCompletionBlock not set.")
      }

      completion(items, error)
    }
  }

  public var fetchRecordZonesCompletionBlock: (([CKRecordZone.ID: CKRecordZone]?, Error?) -> Void)?
}
