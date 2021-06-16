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
      try verifyErrorPropagation(
        simulation: { container, _ in
          let publisher = container.accountStatus()
          return try wait(for: \.completion, from: publisher)
        }
      )
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
          return try wait(for: \.completion, from: fetch)
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
          return try wait(for: \.completion, from: fetch)
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
          return try wait(for: \.completion, from: query)
        }
      )
    }

    private func verifyErrorPropagation(
      prepare: ((CCKContainer, CCKDatabase) throws -> Void) = { _, _ in },
      simulation: ((CCKContainer, CCKDatabase) throws -> Subscribers.Completion<Error>)
    ) rethrows {
      let space = DecisionSpace()
      repeat {
        let container = MockContainer()
        let database = MockDatabase()
        let factory = MockOperationFactory(database)
        CombineCloudKit.operationFactory = factory

        // Prepare without error injection.
        try prepare(container, database)

        container.space = space
        database.space = space
        factory.space = space

        // Simulate the test scenario with error injection.
        let completion = try simulation(container, database)
        if case .failure(let error) = completion,
          let mockError = error as? MockError,
          case MockError.simulated = mockError
        {
          XCTAssert(space.decidedAffirmatively())
        } else {
          XCTAssertFalse(space.decidedAffirmatively())
        }
      } while space.reset()
    }
  }

#endif
