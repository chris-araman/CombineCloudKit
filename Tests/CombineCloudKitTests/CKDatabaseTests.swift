//
//  CKDatabaseTests.swift
//
//
//  Created by Chris Araman on 2/16/21.
//

import CloudKit
import Combine
import CombineExpectations
import XCTest

@testable import CombineCloudKit

final class CKDatabaseTests: CombineCloudKitTests {
  func testSaveFetchAndDeleteAtBackgroundPriority() throws {
    let record = CKRecord(recordType: "Test")
    let database = container.privateCloudDatabase
    let save = database.saveAtBackgroundPriority(record: record)
    let saved = try waitForSingle(from: save)
    XCTAssertEqual(saved.recordID, record.recordID)

    let fetch = database.fetchAtBackgroundPriority(withRecordID: saved.recordID)
    let fetched = try waitForSingle(from: fetch)
    XCTAssertEqual(fetched.recordID, record.recordID)

    let delete = database.deleteAtBackgroundPriority(recordID: saved.recordID)
    let deleted = try waitForSingle(from: delete)
    XCTAssertEqual(deleted, record.recordID)
  }

  func testSaveFetchAndDelete() throws {
    let record = CKRecord(recordType: "Test")
    let database = container.privateCloudDatabase
    let save = database.save(record: record)
    let saved = try waitForLast(from: save).0
    XCTAssertEqual(saved.recordID, record.recordID)

    let fetch = database.fetch(recordID: saved.recordID)
    let fetched = try XCTUnwrap(try waitForLast(from: fetch).1)
    XCTAssertEqual(fetched.recordID, record.recordID)

    let delete = database.delete(recordID: saved.recordID)
    let deleted = try waitForSingle(from: delete)
    XCTAssertEqual(deleted, record.recordID)
  }
}
