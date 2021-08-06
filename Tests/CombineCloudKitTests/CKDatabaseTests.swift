//
//  CKDatabaseTests.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/16/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine
import XCTest

@testable import CombineCloudKit
@testable import enum CombineCloudKit.Progress

final class CKDatabaseTests: CombineCloudKitTests {
  func testDeleteRecordFailsWhenDoesNotExist() throws {
    let record = CKRecord(recordType: "Test")
    let delete = database.delete(recordID: record.recordID)
    XCTAssertThrowsError(try waitForSingle(from: delete))
  }

  func testDeleteRecordZoneFailsWhenDoesNotExist() throws {
    let zone = CKRecordZone(zoneName: "Test")
    let delete = database.delete(recordZoneID: zone.zoneID)
    XCTAssertThrowsError(try waitForSingle(from: delete))
  }

  func testDeleteSubscriptionFailsWhenDoesNotExist() throws {
    let subscription = CKDatabaseSubscription(subscriptionID: "Test")
    let delete = database.delete(subscriptionID: subscription.subscriptionID)
    XCTAssertThrowsError(try waitForSingle(from: delete))
  }

  func testDeleteRecordAtBackgroundPriorityFailsWhenDoesNotExist() throws {
    let record = CKRecord(recordType: "Test")
    let delete = database.deleteAtBackgroundPriority(recordID: record.recordID)
    XCTAssertThrowsError(try waitForSingle(from: delete))
  }

  func testDeleteRecordZoneAtBackgroundPriorityFailsWhenDoesNotExist() throws {
    let zone = CKRecordZone(zoneName: "Test")
    let delete = database.deleteAtBackgroundPriority(recordZoneID: zone.zoneID)
    XCTAssertThrowsError(try waitForSingle(from: delete))
  }

  func testDeleteSubscriptionAtBackgroundPriorityFailsWhenDoesNotExist() throws {
    let subscription = CKDatabaseSubscription(subscriptionID: "Test")
    let delete = database.deleteAtBackgroundPriority(subscriptionID: subscription.subscriptionID)
    XCTAssertThrowsError(try waitForSingle(from: delete))
  }

  func testFetchRecordFailsWhenDoesNotExist() throws {
    let record = CKRecord(recordType: "Test")
    let fetch = database.fetch(recordID: record.recordID)
    XCTAssertThrowsError(try waitForSingle(from: fetch))
  }

  func testFetchRecordWithProgressFailsWhenDoesNotExist() throws {
    let record = CKRecord(recordType: "Test")
    let fetch = database.fetchWithProgress(recordID: record.recordID)
    XCTAssertThrowsError(try waitForSingle(from: fetch))
  }

  func testFetchRecordZoneFailsWhenDoesNotExist() throws {
    let zone = CKRecordZone(zoneName: "Test")
    let fetch = database.fetch(recordZoneID: zone.zoneID)
    XCTAssertThrowsError(try waitForSingle(from: fetch))
  }

  func testFetchSubscriptionFailsWhenDoesNotExist() throws {
    let subscription = CKDatabaseSubscription(subscriptionID: "Test")
    let fetch = database.fetch(subscriptionID: subscription.subscriptionID)
    XCTAssertThrowsError(try waitForSingle(from: fetch))
  }

  func testFetchRecordAtBackgroundPriorityFailsWhenDoesNotExist() throws {
    let record = CKRecord(recordType: "Test")
    let fetch = database.fetchAtBackgroundPriority(withRecordID: record.recordID)
    XCTAssertThrowsError(try waitForSingle(from: fetch))
  }

  func testFetchRecordZoneAtBackgroundPriorityFailsWhenDoesNotExist() throws {
    let zone = CKRecordZone(zoneName: "Test")
    let fetch = database.fetchAtBackgroundPriority(withRecordZoneID: zone.zoneID)
    XCTAssertThrowsError(try waitForSingle(from: fetch))
  }

  func testFetchSubscriptionAtBackgroundPriorityFailsWhenDoesNotExist() throws {
    let subscription = CKDatabaseSubscription(subscriptionID: "Test")
    let fetch = database.fetchAtBackgroundPriority(
      withSubscriptionID: subscription.subscriptionID)
    XCTAssertThrowsError(try waitForSingle(from: fetch))
  }

  func testFetchRecordsIncludesOnlyRequestedRecords() throws {
    let records = (1...3).map { CKRecord(recordType: "Test\($0)") }
    let save = database.save(records: records)
    try waitForFinished(from: save)

    let fetch = database.fetch(recordIDs: [records[0].recordID, records[1].recordID])
    let fetched = try waitForElements(from: fetch)
    XCTAssertEqual(Set(fetched), Set(records[0...1]))
  }

  func testFetchRecordZonesIncludesOnlyRequestedRecordZones() throws {
    let zones = (1...3).map { CKRecordZone(zoneName: "Test\($0)") }
    let save = database.save(recordZones: zones)
    try waitForFinished(from: save)

    let fetch = database.fetch(recordZoneIDs: [zones[0].zoneID, zones[1].zoneID])
    let fetched = try waitForElements(from: fetch)
    XCTAssertEqual(Set(fetched), Set(zones[0...1]))
  }

  func testFetchSubscriptionsIncludesOnlyRequestedSubscriptions() throws {
    let subscriptions = (1...3).map { CKDatabaseSubscription(subscriptionID: "Test\($0)") }
    let save = database.save(subscriptions: subscriptions)
    let saved = try waitForElements(from: save)
    XCTAssertEqual(Set(saved), Set(subscriptions[0...2]))

    let fetch = database.fetch(subscriptionIDs: [
      subscriptions[0].subscriptionID,
      subscriptions[1].subscriptionID,
    ])
    let fetched = try waitForElements(from: fetch)
    XCTAssertEqual(Set(fetched), Set(subscriptions[0...1]))
  }

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
      { $0.recordID },
      database.saveAtBackgroundPriority,
      database.fetchAtBackgroundPriority,
      database.deleteAtBackgroundPriority)
  }

  func testSaveFetchAndDeleteRecordWithProgress() throws {
    let configuration = CKOperation.Configuration()
    let record = CKRecord(recordType: "Test")
    let save = database.saveWithProgress(record: record, withConfiguration: configuration)
    let saved = try validateSaveProgressOfSingleRecord(from: save)
    XCTAssertEqual(saved.recordID, record.recordID)

    let fetch = database.fetchWithProgress(
      recordID: saved.recordID, withConfiguration: configuration)
    let fetched = try validateFetchProgressOfSingleRecord(from: fetch)
    XCTAssertEqual(fetched.recordID, record.recordID)

    let delete = database.delete(recordID: saved.recordID, withConfiguration: configuration)
    let deleted = try waitForSingle(from: delete)
    XCTAssertEqual(deleted, record.recordID)
  }

  func testSaveFetchAndDeleteRecordZone() throws {
    try validateSaveFetchAndDelete(
      { CKRecordZone(zoneName: "Test") },
      { $0.zoneID },
      database.save,
      database.fetch,
      database.delete)
  }

  func testSaveFetchAndDeleteRecordZoneAtBackgroundPriority() throws {
    try validateSaveFetchAndDelete(
      { CKRecordZone(zoneName: "Test") },
      { $0.zoneID },
      database.saveAtBackgroundPriority,
      database.fetchAtBackgroundPriority,
      database.deleteAtBackgroundPriority)
  }

  func testSaveFetchAndDeleteSubscription() throws {
    try validateSaveFetchAndDelete(
      { CKDatabaseSubscription(subscriptionID: "Test") },
      { $0.subscriptionID },
      database.save,
      database.fetch,
      database.delete)
  }

  func testSaveFetchAndDeleteSubscriptionAtBackgroundPriority() throws {
    try validateSaveFetchAndDelete(
      { CKDatabaseSubscription(subscriptionID: "Test") },
      { $0.subscriptionID },
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
    let elements = try waitForElements(from: publisher)
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
    let elements = try waitForElements(from: publisher)
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
      Set(records.map({ $0.recordID })),
      Set(recordProgress.keys),
      "Progress was reported for a different set of records than was output.")

    return records
  }

  private func validateSaveFetchAndDelete<T, ID>(
    _ create: () -> T,
    _ id: (T) -> ID,
    _ save: (T, CKOperation.Configuration?) -> AnyPublisher<T, Error>,
    _ fetch: (ID, CKOperation.Configuration?) -> AnyPublisher<T, Error>,
    _ delete: (ID, CKOperation.Configuration?) -> AnyPublisher<ID, Error>
  ) throws where ID: Equatable {
    let configuration = CKOperation.Configuration()
    try validateSaveFetchAndDelete(
      create,
      id,
      { item in save(item, configuration) },
      { itemID in fetch(itemID, configuration) },
      { itemID in delete(itemID, configuration) }
    )
  }

  private func validateSaveFetchAndDelete<T, ID>(
    _ create: () -> T,
    _ id: (T) -> ID,
    _ save: (T) -> AnyPublisher<T, Error>,
    _ fetch: (ID) -> AnyPublisher<T, Error>,
    _ delete: (ID) -> AnyPublisher<ID, Error>
  ) throws where ID: Equatable {
    let item = create()
    let itemID = id(item)
    let save = save(item)
    let saved = try waitForSingle(from: save)
    XCTAssertEqual(id(saved), itemID)

    let fetch = fetch(itemID)
    let fetched = try waitForSingle(from: fetch)
    XCTAssertEqual(id(fetched), itemID)

    let delete = delete(itemID)
    let deleted = try waitForSingle(from: delete)
    XCTAssertEqual(deleted, itemID)
  }

  func testFetchAllRecordZones() throws {
    let configuration = CKOperation.Configuration()
    try validateFetchAll(
      (1...3).map { CKRecordZone(zoneName: "\($0)") },
      database.save,
      { () in database.fetchAllRecordZones(withConfiguration: configuration) }
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
    try waitForFinished(from: save)

    let configuration = CKOperation.Configuration()
    let desiredKeys = ["Key"]
    let fetch = database.fetchCurrentUserRecord(
      desiredKeys: desiredKeys, withConfiguration: configuration)
    let fetched = try waitForSingle(from: fetch)
    XCTAssertEqual(fetched, userRecord)
  }

  func testFetchAllSubscriptions() throws {
    let configuration = CKOperation.Configuration()
    try validateFetchAll(
      (1...3).map { CKDatabaseSubscription(subscriptionID: "\($0)") },
      database.save,
      { () in database.fetchAllSubscriptions(withConfiguration: configuration) }
    )
  }

  func testFetchAllSubscriptionsAtBackgroundPriority() throws {
    try validateFetchAll(
      (1...3).map { CKDatabaseSubscription(subscriptionID: "\($0)") },
      database.save,
      database.fetchAllSubscriptionsAtBackgroundPriority
    )
  }

  private func validateFetchAll<T>(
    _ items: [T],
    _ save: ([T], CKOperation.Configuration?) -> AnyPublisher<T, Error>,
    _ fetch: () -> AnyPublisher<T, Error>
  ) throws where T: Hashable {
    let configuration = CKOperation.Configuration()
    let save = save(items, configuration)
    try waitForFinished(from: save)

    let fetch = fetch()
    let fetched = try waitForElements(from: fetch)
    XCTAssertEqual(Set(fetched), Set(items))
  }

  func testQueryWithNoRecordsReturnsNoResults() throws {
    let query = database.performQuery(ofType: "Test")
    let results = try waitForElements(from: query)
    XCTAssertEqual(Set(results), Set())
  }

  func testQueryWithNoMatchingRecordsReturnsNoResults() throws {
    let save = database.save(record: CKRecord(recordType: "Test"))
    try waitForFinished(from: save)

    let query = database.performQuery(ofType: "NonMatching")
    let results = try waitForElements(from: query)
    XCTAssertEqual(Set(results), Set())
  }

  func testQueryReturnsExpectedResults() throws {
    let configuration = CKOperation.Configuration()
    let records = (0...9).map {
      CKRecord(recordType: "Test", recordID: CKRecord.ID(recordName: "\($0)"))
    }
    let save = database.save(records: records, withConfiguration: configuration)
    try waitForFinished(from: save)

    // MockQueryOperation returns every second record of matching type, sorted by ID.recordName.
    let query = database.performQuery(ofType: "Test", withConfiguration: configuration)
    let results = try waitForElements(from: query)
    XCTAssertEqual(Set(results), Set(stride(from: 0, to: 9, by: 2).map { records[$0 + 1] }))
  }

  private class Paginator: Subscriber, Cancellable {
    typealias Input = CKRecord
    typealias Failure = Error

    private let queue = DispatchQueue(label: "Paginator")
    private var subscription: Subscription?
    private var records = [CKRecord]()
    private var error: Error?
    private let testCase: XCTestCase
    private var expectation: XCTestExpectation?

    init(testCase: XCTestCase) {
      self.testCase = testCase
    }

    func receive(subscription: Subscription) {
      queue.sync {
        self.subscription = subscription
      }
    }

    func receive(_ input: CKRecord) -> Subscribers.Demand {
      queue.sync {
        records.append(input)
        return .none
      }
    }

    func receive(completion: Subscribers.Completion<Error>) {
      queue.sync {
        if case .failure(let error) = completion {
          self.error = error
        }

        expectation?.fulfill()
        expectation = nil
      }
    }

    func cancel() {
      queue.sync {
        subscription?.cancel()
        subscription = nil
        expectation?.fulfill()
        expectation = nil
      }
    }

    func next(_ pageSize: Int) throws -> [CKRecord] {
      var expect: XCTestExpectation?
      queue.sync {
        records.removeAll()
        assert(expectation == nil)
        guard let subscription = subscription else {
          return
        }

        if pageSize != 0 {
          expectation = testCase.expectation(description: "Paginator")
        }

        subscription.request(.max(pageSize))
        expect = expectation
      }

      if let expect = expect {
        testCase.wait(for: [expect], timeout: 1)
      }

      if let error = error {
        throw error
      }

      return records
    }
  }

  func testQueryWithPaginationReturnsExpectedResults() throws {
    let records = (0...9).map {
      CKRecord(recordType: "Test", recordID: CKRecord.ID(recordName: "\($0)"))
    }
    let save = database.save(records: records)
    try waitForFinished(from: save)

    // MockQueryOperation returns every second record of matching type, sorted by ID.recordName.
    let paginator = Paginator(testCase: self)
    let query = database.performQuery(ofType: "Test")
    query.receive(subscriber: paginator)
    XCTAssertEqual(try paginator.next(2), [records[1], records[3]])

    // TODO: Test that a second page picks up where the first left off.
    // XCTAssertEqual(paginator.nextPage(), [records[5], records[7]])
  }

  func testQueryForZeroRecordsReturnsNoRecords() throws {
    let paginator = Paginator(testCase: self)
    let query = database.performQuery(ofType: "Test")
    query.receive(subscriber: paginator)
    XCTAssertEqual(try paginator.next(0), [])
  }

  func testQueryAfterCancellationReturnsNoRecords() {
    let paginator = Paginator(testCase: self)
    let query = database.performQuery(ofType: "Test")
    query.receive(subscriber: paginator)
    paginator.cancel()
    XCTAssertEqual(try paginator.next(1), [])
  }

  func testCKOperationFactory() {
    let factory = CKOperationFactory()
    _ = factory.createFetchAllRecordZonesOperation()
    _ = factory.createFetchAllSubscriptionsOperation()
    _ = factory.createFetchCurrentUserRecordOperation()
    _ = factory.createFetchRecordsOperation(recordIDs: [])
    _ = factory.createFetchRecordZonesOperation(recordZoneIDs: [])
    _ = factory.createFetchSubscriptionsOperation(subscriptionIDs: [])
    _ = factory.createModifyRecordsOperation(
      recordsToSave: nil,
      recordIDsToDelete: nil
    )
    _ = factory.createModifyRecordZonesOperation(
      recordZonesToSave: nil,
      recordZoneIDsToDelete: nil
    )
    _ = factory.createModifySubscriptionsOperation(
      subscriptionsToSave: nil,
      subscriptionIDsToDelete: nil
    )
    _ = factory.createQueryOperation()
  }
}
