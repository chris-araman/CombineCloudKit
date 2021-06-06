//
//  MockFetchRecordsOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import CombineCloudKit

public class MockFetchRecordsOperation: MockDatabaseOperation, CCKFetchRecordsOperation {
  let recordIDs: [CKRecord.ID]

  init(_ database: MockDatabase, _ recordIDs: [CKRecord.ID]) {
    self.recordIDs = recordIDs
    super.init(database)
  }

  public var desiredKeys: [CKRecord.FieldKey]?

  public var perRecordProgressBlock: ((CKRecord.ID, Double) -> Void)?

  public var perRecordCompletionBlock: ((CKRecord?, CKRecord.ID?, Error?) -> Void)?

  public var fetchRecordsCompletionBlock: (([CKRecord.ID: CKRecord]?, Error?) -> Void)?

  public override func start() {
    guard let completion = fetchRecordsCompletionBlock else {
      // TODO: XCTFail
      fatalError("fetchRecordsCompletionBlock not set.")
    }

    mockDatabase.queue.async {
      guard self.recordIDs.allSatisfy(self.mockDatabase.records.keys.contains) else {
        completion(nil, MockError.doesNotExist)
        return
      }

      let records = self.mockDatabase.records.filter { recordID, record in
        guard self.recordIDs.contains(recordID) else {
          return false
        }

        if let progress = self.perRecordProgressBlock {
          // TODO: Use some other progress values.
          progress(recordID, 1.0)
        }

        if let completion = self.perRecordCompletionBlock {
          // TODO: Should this return CKRecord.ID on success?
          completion(record, nil, nil)
        }

        return true
      }

      // TODO: Simulate failures.
      completion(records, nil)
    }
  }
}
