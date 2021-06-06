//
//  MockFetchRecordZonesOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import CombineCloudKit

public class MockFetchRecordZonesOperation: MockDatabaseOperation, CCKFetchRecordZonesOperation {
  let recordZoneIDs: [CKRecordZone.ID]?

  init(_ database: MockDatabase, _ recordZoneIDs: [CKRecordZone.ID]? = nil) {
    self.recordZoneIDs = recordZoneIDs
    super.init(database)
  }

  public var fetchRecordZonesCompletionBlock: (([CKRecordZone.ID: CKRecordZone]?, Error?) -> Void)?

  public override func start() {
    guard let completion = fetchRecordZonesCompletionBlock else {
      // TODO: XCTFail
      fatalError("fetchRecordZonesCompletionBlock not set.")
    }

    mockDatabase.queue.async {
      guard let recordZoneIDs = self.recordZoneIDs else {
        completion(self.mockDatabase.recordZones, nil)
        return
      }

      guard recordZoneIDs.allSatisfy(self.mockDatabase.recordZones.keys.contains) else {
        completion(nil, MockError.doesNotExist)
        return
      }

      let recordZones = self.mockDatabase.recordZones.filter { recordZoneID, _ in
        recordZoneIDs.contains(recordZoneID)
      }

      // TODO: Simulate failures.
      completion(recordZones, nil)
    }
  }
}
