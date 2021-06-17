//
//  ErrorInjectionTests.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 5/7/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine
import XCTest

@testable import CombineCloudKit

#if canImport(CombineExpectations) && canImport(XCTest)

  class ErrorInjectionTests: CombineCloudKitTests {
    func testAccountStatusPropagatesErrors() throws {
      try verifyErrorPropagation { container, _ in
        let publisher = container.accountStatus()
        try wait(for: \.finished, from: publisher)
      }
    }

    func testSaveFetchAndDeleteRecords() throws {
      try validateSaveFetchAndDelete(
        { CKRecord(recordType: "Test") },
        \.recordID,
        { database in { record in database.save(record: record) } },
        { database in { recordID in database.fetch(recordID: recordID) } },
        { database in { recordID in database.delete(recordID: recordID) } }
      )
    }

    func testSaveFetchAndDeleteRecordZones() throws {
      try validateSaveFetchAndDelete(
        { CKRecordZone(zoneName: "Test") },
        \.zoneID,
        { database in { zone in database.save(recordZone: zone) } },
        { database in { zoneID in database.fetch(recordZoneID: zoneID) } },
        { database in { zoneID in database.delete(recordZoneID: zoneID) } }
      )
    }

    func testSaveFetchAndDeleteSubscriptions() throws {
      try validateSaveFetchAndDelete(
        { CKDatabaseSubscription(subscriptionID: "Test") },
        \.subscriptionID,
        { database in { subscription in database.save(subscription: subscription) } },
        { database in { subscriptionID in database.fetch(subscriptionID: subscriptionID) } },
        { database in { subscriptionID in database.delete(subscriptionID: subscriptionID) } }
      )
    }

    func testSaveFetchAndDeleteRecordsAtBackgroundPriority() throws {
      try validateSaveFetchAndDelete(
        { CKRecord(recordType: "Test") },
        \.recordID,
        { $0.saveAtBackgroundPriority },
        { $0.fetchAtBackgroundPriority },
        { $0.deleteAtBackgroundPriority }
      )
    }

    func testSaveFetchAndDeleteRecordZonesAtBackgroundPriority() throws {
      try validateSaveFetchAndDelete(
        { CKRecordZone(zoneName: "Test") },
        \.zoneID,
        { $0.saveAtBackgroundPriority },
        { $0.fetchAtBackgroundPriority },
        { $0.deleteAtBackgroundPriority }
      )
    }

    func testSaveFetchAndDeleteSubscriptionsAtBackgroundPriority() throws {
      try validateSaveFetchAndDelete(
        { CKDatabaseSubscription(subscriptionID: "Test") },
        \.subscriptionID,
        { $0.saveAtBackgroundPriority },
        { $0.fetchAtBackgroundPriority },
        { $0.deleteAtBackgroundPriority }
      )
    }

    private func validateSaveFetchAndDelete<T, ID>(
      _ create: () -> T,
      _ id: (T) -> ID,
      _ save: (CCKDatabase) -> ((T) -> AnyPublisher<T, Error>),
      _ fetch: (CCKDatabase) -> ((ID) -> AnyPublisher<T, Error>),
      _ delete: (CCKDatabase) -> ((ID) -> AnyPublisher<ID, Error>)
    ) throws where ID: Equatable {
      try verifyErrorPropagation { _, database in
        let item = create()
        let itemID = id(item)
        let save = save(database)(item)
        try wait(for: \.finished, from: save)

        let fetch = fetch(database)(itemID)
        try wait(for: \.finished, from: fetch)

        let delete = delete(database)(itemID)
        try wait(for: \.finished, from: delete)
      }
    }

    func testFetchAllRecordZones() throws {
      try validateFetchAll(
        (1...3).map { CKRecordZone(zoneName: "\($0)") },
        { $0.save },
        { database in { database.fetchAllRecordZones() } }
      )
    }

    func testFetchAllRecordZonesAtBackgroundPriority() throws {
      try validateFetchAll(
        (1...3).map { CKRecordZone(zoneName: "\($0)") },
        { $0.save },
        { $0.fetchAllRecordZonesAtBackgroundPriority }
      )
    }

    func testFetchCurrentUserRecord() throws {
      try verifyErrorPropagation(
        prepare: { _, database in
          let userRecord = CKRecord(
            recordType: "Test", recordID: MockOperationFactory.currentUserRecordID)
          let save = database.save(record: userRecord)
          try wait(for: \.finished, from: save)
        },
        simulation: { _, database in
          let fetch = database.fetchCurrentUserRecord()
          try wait(for: \.finished, from: fetch)
        }
      )
    }

    func testFetchAllSubscriptions() throws {
      try validateFetchAll(
        (1...3).map { CKDatabaseSubscription(subscriptionID: "\($0)") },
        { $0.save },
        { database in { database.fetchAllSubscriptions() } }
      )
    }

    func testFetchAllSubscriptionsAtBackgroundPriority() throws {
      try validateFetchAll(
        (1...3).map { CKDatabaseSubscription(subscriptionID: "\($0)") },
        { $0.save },
        { $0.fetchAllSubscriptionsAtBackgroundPriority }
      )
    }

    private func validateFetchAll<T>(
      _ items: [T],
      _ save: (CCKDatabase) -> (([T], CKOperation.Configuration?) -> AnyPublisher<T, Error>),
      _ fetch: (CCKDatabase) -> (() -> AnyPublisher<T, Error>)
    ) throws where T: Hashable {
      try verifyErrorPropagation(
        prepare: { _, database in
          let save = save(database)(items, nil)
          try wait(for: \.finished, from: save)
        },
        simulation: { _, database in
          let fetch = fetch(database)()
          try wait(for: \.finished, from: fetch)
        }
      )
    }

    func testQueryPropagatesErrors() throws {
      try verifyErrorPropagation(
        prepare: { _, database in
          let record = CKRecord(recordType: "Test")
          let save = database.save(record: record)
          try wait(for: \.finished, from: save)
        },
        simulation: { _, database in
          let query = database.performQuery(ofType: "Test")
          try wait(for: \.finished, from: query)
        }
      )
    }

    private func verifyErrorPropagation(
      prepare: ((CCKContainer, CCKDatabase) throws -> Void) = { _, _ in },
      simulation: ((CCKContainer, CCKDatabase) throws -> Void)
    ) rethrows {
      let space = DecisionSpace()
      repeat {
        let container = MockContainer()
        let database = MockDatabase()
        let factory = MockOperationFactory(database)
        CombineCloudKit.operationFactory = factory

        // Prepare without error injection.
        // An error thrown here indicates a test defect.
        try prepare(container, database)

        container.space = space
        database.space = space
        factory.space = space

        // Simulate the test scenario with error injection.
        // An error thrown here should have been injected or else the test has failed.
        do {
          try simulation(container, database)
          XCTAssertFalse(
            space.hasDecidedAffirmatively(), "Simulation was expected to fail with injected error.")
        } catch {
          guard let mockError = error as? MockError,
            case MockError.simulated = mockError,
            space.hasDecidedAffirmatively()
          else {
            XCTFail("Simulation failed with unexpected error: \(error.localizedDescription)")
            break
          }
        }

        if !space.hasDecided() {
          XCTFail("Simulation did not make any decisions.")
          break
        }
      } while space.next()
    }
  }

#endif
