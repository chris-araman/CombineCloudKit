//
//  MockQueryOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/15/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import CombineCloudKit

public class MockQueryOperation: MockDatabaseOperation, CCKQueryOperation {
  override init(_ database: MockDatabase, _ space: DecisionSpace?) {
    super.init(database, space)
  }

  public var query: CKQuery?

  public var cursor: CKQueryOperation.Cursor?

  public var desiredKeys: [CKRecord.FieldKey]?

  public var zoneID: CKRecordZone.ID?

  public var resultsLimit: Int = CKQueryOperation.maximumResults

  public var recordFetchedBlock: ((CKRecord) -> Void)?

  public var queryCompletionBlock: ((CKQueryOperation.Cursor?, Error?) -> Void)?

  public override func start() {
    let fetched = try! XCTUnwrap(self.recordFetchedBlock)
    let completion = try! XCTUnwrap(self.queryCompletionBlock)
    mockDatabase.queue.async {
      self.mockDatabase.perform(try! XCTUnwrap(self.query), inZoneWith: self.zoneID) {
        results, error in
        if let space = self.space, space.decide() {
          completion(nil, MockError.simulated)
          return
        }

        guard let results = results else {
          completion(nil, error!)
          return
        }

        var resultsReturned = 0
        for record in results {
          guard
            self.resultsLimit == CKQueryOperation.maximumResults
              || resultsReturned < self.resultsLimit
          else {
            // FIXME: We can't actually create a Cursor.
            completion(nil, nil)
            return
          }

          resultsReturned += 1
          fetched(record)
        }

        completion(nil, nil)
      }
    }
  }
}
