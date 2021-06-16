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
        { $0.save },
        { database in { recordID, _ in database.fetch(recordID: recordID) }},
        { $0.delete }
      )
    }

    func testSaveFetchAndDeleteRecordZones() throws {
      try validateSaveFetchAndDelete(
        { CKRecordZone(zoneName: "Test") },
        \.zoneID,
        { $0.save },
        { $0.fetch },
        { $0.delete }
      )
    }

    func testSaveFetchAndDeleteSubscriptions() throws {
      try validateSaveFetchAndDelete(
        { CKDatabaseSubscription(subscriptionID: "Test") },
        \.subscriptionID,
        { $0.save },
        { $0.fetch },
        { $0.delete }
      )
    }

    private func validateSaveFetchAndDelete<T, ID>(
      _ create: () -> T,
      _ id: (T) -> ID,
      _ save: (CCKDatabase) -> ((T, CKOperation.Configuration?) -> AnyPublisher<T, Error>),
      _ fetch: (CCKDatabase) -> ((ID, CKOperation.Configuration?) -> AnyPublisher<T, Error>),
      _ delete: (CCKDatabase) -> ((ID, CKOperation.Configuration?) -> AnyPublisher<ID, Error>)
    ) throws where ID: Equatable {
      try verifyErrorPropagation { _, database in
        let item = create()
        let itemID = id(item)
        let save = save(database)(item, nil)
        try wait(for: \.finished, from: save)

        let fetch = fetch(database)(itemID, nil)
        try wait(for: \.finished, from: fetch)

        let delete = delete(database)(itemID, nil)
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
            recordType: "CurrentUserRecord", recordID: MockOperationFactory.currentUserRecordID)
          let save = database.save(record: userRecord)
          try wait(for: \.finished, from: save)
        },
        simulation: { _, database in
          let desiredKeys = ["Key"]
          let fetch = database.fetchCurrentUserRecord(desiredKeys: desiredKeys)
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
          XCTAssertFalse(space.decidedAffirmatively(), "Simulation was expected to fail with injected error.")
        } catch {
          guard let mockError = error as? MockError,
            case MockError.simulated = mockError,
            space.decidedAffirmatively() else
          {
            XCTFail("Simulation failed with unexpected error: \(error.localizedDescription)")
            break
          }
        }
      } while space.reset()
    }
  }

#endif
