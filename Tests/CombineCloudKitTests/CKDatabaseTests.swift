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
@testable import enum CombineCloudKit.Progress

final class CKDatabaseTests: CombineCloudKitTests {
  func testSaveFetchAndDelete() throws {
    let record = CKRecord(recordType: "Test")
    let database = container.privateCloudDatabase
    let save = database.save(record: record)
    let saved = try wait(for: \.single, from: save)
    XCTAssertEqual(saved.recordID, record.recordID)

    let fetch = database.fetch(recordID: saved.recordID)
    let fetched = try wait(for: \.single, from: fetch)
    XCTAssertEqual(fetched.recordID, record.recordID)

    let delete = database.delete(recordID: saved.recordID)
    let deleted = try wait(for: \.single, from: delete)
    XCTAssertEqual(deleted, record.recordID)
  }

  func testSaveFetchAndDeleteAtBackgroundPriority() throws {
    let record = CKRecord(recordType: "Test")
    let database = container.privateCloudDatabase
    let save = database.saveAtBackgroundPriority(record: record)
    let saved = try wait(for: \.single, from: save)
    XCTAssertEqual(saved.recordID, record.recordID)

    let fetch = database.fetchAtBackgroundPriority(withRecordID: saved.recordID)
    let fetched = try wait(for: \.single, from: fetch)
    XCTAssertEqual(fetched.recordID, record.recordID)

    let delete = database.deleteAtBackgroundPriority(recordID: saved.recordID)
    let deleted = try wait(for: \.single, from: delete)
    XCTAssertEqual(deleted, record.recordID)
  }

  func testSaveFetchAndDeleteWithProgress() throws {
    let record = CKRecord(recordType: "Test")
    let database = container.privateCloudDatabase
    let save = database.saveWithProgress(record: record)
    let saved = try validateProgressOfSingleRecord(from: save)
    XCTAssertEqual(saved.recordID, record.recordID)

    let fetch = database.fetchWithProgress(recordID: saved.recordID)
    let fetched = try validateProgressOfSingleRecord(from: fetch)
    XCTAssertEqual(fetched.recordID, record.recordID)

    let delete = database.delete(recordID: saved.recordID)
    let deleted = try wait(for: \.single, from: delete)
    XCTAssertEqual(deleted, record.recordID)
  }

  private func validateProgressOfSingleRecord<P, T>(from publisher: P)
  throws -> T where P: Publisher, T: Hashable, P.Output == (T, Progress) {
    let records = try validateProgress(from: publisher)
    XCTAssertEqual(records.count, 1)
    return records.first!
  }

  private func validateProgressOfSingleRecord<P>(from publisher: P)
  throws -> CKRecord where P: Publisher, P.Output == ((CKRecord.ID, Progress)?, CKRecord?) {
    let records = try validateProgress(from: publisher)
    XCTAssertEqual(records.count, 1)
    return records.first!
  }

  private func validateProgress<P, T>(from publisher: P)
  throws -> [T] where P: Publisher, T: Hashable, P.Output == (T, Progress) {
    var recordProgress: [T: Progress] = [:]
    let elements = try wait(for: \.elements, from: publisher)
    for (recordID, progress) in elements {
      if let latest = recordProgress[recordID] {
        XCTAssertGreaterThan(
          progress, latest, "Received a progress update that was not more complete than a previous update.")
      }

      recordProgress[recordID] = progress
    }

    for (recordID, progress) in recordProgress {
      XCTAssertEqual(progress, .complete, "Record was not complete: \(recordID)")
    }

    return Array(recordProgress.keys)
  }

  private func validateProgress<P>(from publisher: P)
  throws -> [CKRecord] where P: Publisher, P.Output == ((CKRecord.ID, Progress)?, CKRecord?) {
    var records: [CKRecord] = []
    var recordProgress: [CKRecord.ID: Progress] = [:]
    let elements = try wait(for: \.elements, from: publisher)
    for (update, record) in elements {
      guard let record = record else {
        guard let (recordID, progress) = update else {
          XCTFail("Output received with neither a progress update nor a record.")
          continue
        }

        if let latest = recordProgress[recordID] {
          XCTAssertGreaterThan(
            progress, latest, "Received a progress update that was not more complete than a previous update.")
        }

        recordProgress[recordID] = progress
        continue
      }

      records.append(record)
    }

    for (recordID, progress) in recordProgress {
      XCTAssertEqual(progress, .complete, "Record was not complete: \(recordID)")
    }

    XCTAssertEqual(
      Set(records.map(\.recordID)),
      Set(recordProgress.keys),
      "Progress was reported for a different set of records than was output.")

    return records
  }
}
