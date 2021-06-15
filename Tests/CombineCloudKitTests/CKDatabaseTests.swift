//
//  CKDatabaseTests.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/16/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

#if canImport(CombineExpectations) && canImport(XCTest)

  import CloudKit
  import Combine
  import CombineExpectations
  import XCTest

  @testable import CombineCloudKit
  @testable import enum CombineCloudKit.Progress

  final class CKDatabaseTests: CombineCloudKitTests {
    func testSaveFetchAndDeleteRecord() throws {
      try validateSaveFetchAndDelete(
        { CKRecord(recordType: "Test") },
        { record in record.recordID },
        { record in database.save(record: record) },
        { recordID in database.fetch(recordID: recordID) },
        { recordID in database.delete(recordID: recordID) }
      )
    }

    func testSaveFetchAndDeleteRecordAtBackgroundPriority() throws {
      try validateSaveFetchAndDelete(
        { CKRecord(recordType: "Test") },
        \.recordID,
        database.saveAtBackgroundPriority,
        database.fetchAtBackgroundPriority,
        database.deleteAtBackgroundPriority)
    }

    func testSaveFetchAndDeleteRecordWithProgress() throws {
      let record = CKRecord(recordType: "Test")
      let save = database.saveWithProgress(record: record)
      let saved = try validateSaveProgressOfSingleRecord(from: save)
      XCTAssertEqual(saved.recordID, record.recordID)

      let fetch = database.fetchWithProgress(recordID: saved.recordID)
      let fetched = try validateFetchProgressOfSingleRecord(from: fetch)
      XCTAssertEqual(fetched.recordID, record.recordID)

      let delete = database.delete(recordID: saved.recordID)
      let deleted = try wait(for: \.single, from: delete)
      XCTAssertEqual(deleted, record.recordID)
    }

    func testSaveFetchAndDeleteRecordZone() throws {
      try validateSaveFetchAndDelete(
        { CKRecordZone(zoneName: "Test") },
        \.zoneID,
        database.save,
        database.fetch,
        database.delete)
    }

    func testSaveFetchAndDeleteRecordZoneAtBackgroundPriority() throws {
      try validateSaveFetchAndDelete(
        { CKRecordZone(zoneName: "Test") },
        \.zoneID,
        database.saveAtBackgroundPriority,
        database.fetchAtBackgroundPriority,
        database.deleteAtBackgroundPriority)
    }

    func testSaveFetchAndDeleteSubscription() throws {
      try validateSaveFetchAndDelete(
        { CKDatabaseSubscription(subscriptionID: "Test") },
        \.subscriptionID,
        database.save,
        database.fetch,
        database.delete)
    }

    func testSaveFetchAndDeleteSubscriptionAtBackgroundPriority() throws {
      try validateSaveFetchAndDelete(
        { CKDatabaseSubscription(subscriptionID: "Test") },
        \.subscriptionID,
        database.saveAtBackgroundPriority,
        database.fetchAtBackgroundPriority,
        database.deleteAtBackgroundPriority)
    }

    private func validateSaveProgressOfSingleRecord<P, T>(from publisher: P)
      throws -> T where P: Publisher, T: Hashable, P.Output == (T, Progress)
    {
      let records = try validateSaveProgress(from: publisher)
      XCTAssertEqual(records.count, 1)
      return try XCTUnwrap(records.first)
    }

    private func validateFetchProgressOfSingleRecord<P>(from publisher: P)
      throws -> CKRecord where P: Publisher, P.Output == ((CKRecord.ID, Progress)?, CKRecord?)
    {
      let records = try validateFetchProgress(from: publisher)
      XCTAssertEqual(records.count, 1)
      return try XCTUnwrap(records.first)
    }

    private func validateSaveProgress<P, T>(from publisher: P)
      throws -> [T] where P: Publisher, T: Hashable, P.Output == (T, Progress)
    {
      var recordProgress: [T: Progress] = [:]
      let elements = try wait(for: \.elements, from: publisher)
      for (recordID, progress) in elements {
        if let latest = recordProgress[recordID] {
          XCTAssertGreaterThan(
            progress, latest,
            "Received a progress update that was not more complete than a previous update.")
        }

        recordProgress[recordID] = progress
      }

      for (recordID, progress) in recordProgress {
        XCTAssertEqual(progress, .complete, "Record was not complete: \(recordID)")
      }

      return Array(recordProgress.keys)
    }

    private func validateFetchProgress<P>(from publisher: P)
      throws -> [CKRecord] where P: Publisher, P.Output == ((CKRecord.ID, Progress)?, CKRecord?)
    {
      var records: [CKRecord] = []
      var recordProgress: [CKRecord.ID: Progress] = [:]
      let elements = try wait(for: \.elements, from: publisher)
      for (update, record) in elements {
        guard let record = record else {
          let (recordID, progress) = try XCTUnwrap(update)
          if let latest = recordProgress[recordID] {
            XCTAssertGreaterThan(
              progress, latest,
              "Received a progress update that was not more complete than a previous update.")
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

    func validateSaveFetchAndDelete<T, ID>(
      _ create: () -> T,
      _ id: (T) -> ID,
      _ save: (T, CKOperation.Configuration?) -> AnyPublisher<T, Error>,
      _ fetch: (ID, CKOperation.Configuration?) -> AnyPublisher<T, Error>,
      _ delete: (ID, CKOperation.Configuration?) -> AnyPublisher<ID, Error>
    ) throws where ID: Equatable {
      // TODO: Test with configuration.
      try validateSaveFetchAndDelete(
        create,
        id,
        { item in save(item, nil) },
        { itemID in fetch(itemID, nil) },
        { itemID in delete(itemID, nil) }
      )
    }

    func validateSaveFetchAndDelete<T, ID>(
      _ create: () -> T,
      _ id: (T) -> ID,
      _ save: (T) -> AnyPublisher<T, Error>,
      _ fetch: (ID) -> AnyPublisher<T, Error>,
      _ delete: (ID) -> AnyPublisher<ID, Error>
    ) throws where ID: Equatable {
      let item = create()
      let save = save(item)
      let saved = try wait(for: \.single, from: save)
      XCTAssertEqual(id(saved), id(item))

      let fetch = fetch(id(saved))
      let fetched = try wait(for: \.single, from: fetch)
      XCTAssertEqual(id(fetched), id(item))

      let delete = delete(id(saved))
      let deleted = try wait(for: \.single, from: delete)
      XCTAssertEqual(deleted, id(item))
    }

    func testFetchAllRecordZones() throws {
      // TODO: Test with configuration.
      try validateFetchAll(
        (1...3).map { CKRecordZone(zoneName: "\($0)") },
        database.save,
        { () in database.fetchAllRecordZones(withConfiguration: nil) }
      )
    }

    func testFetchAllRecordZonesAtBackgroundPriority() throws {
      try validateFetchAll(
        (1...3).map { CKRecordZone(zoneName: "\($0)") },
        database.save,
        database.fetchAllRecordZonesAtBackgroundPriority
      )
    }

    func testFetchCurrentUserRecord() throws {
      let userRecord = CKRecord(
        recordType: "CurrentUserRecord", recordID: MockOperationFactory.currentUserRecordID)
      let save = database.save(record: userRecord)
      let saved = try wait(for: \.single, from: save)
      XCTAssertEqual(saved, userRecord)

      // TODO: Test with configuration.
      // TODO: Test with desired keys.
      let fetch = database.fetchCurrentUserRecord(desiredKeys: nil, withConfiguration: nil)
      let fetched = try wait(for: \.single, from: fetch)
      XCTAssertEqual(fetched, userRecord)
    }

    func testFetchAllSubscriptions() throws {
      // TODO: Test with configuration.
      try validateFetchAll(
        (1...3).map { CKDatabaseSubscription(subscriptionID: "\($0)") },
        database.save,
        { () in database.fetchAllSubscriptions(withConfiguration: nil) }
      )
    }

    func testFetchAllSubscriptionsAtBackgroundPriority() throws {
      try validateFetchAll(
        (1...3).map { CKDatabaseSubscription(subscriptionID: "\($0)") },
        database.save,
        database.fetchAllSubscriptionsAtBackgroundPriority
      )
    }

    func validateFetchAll<T>(
      _ items: [T],
      _ save: ([T], CKOperation.Configuration?) -> AnyPublisher<T, Error>,
      _ fetch: () -> AnyPublisher<T, Error>
    ) throws where T: Hashable {
      // TODO: Test with configuration.
      let save = save(items, nil)
      let saved = try wait(for: \.elements, from: save)
      XCTAssertEqual(Set(saved), Set(items))

      let fetch = fetch()
      let fetched = try wait(for: \.elements, from: fetch)
      XCTAssertEqual(Set(fetched), Set(items))
    }
  }

#endif
