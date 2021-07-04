//
//  CombineCloudKitTests.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 5/7/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

#if canImport(CombineExpectations) && canImport(XCTest)

  import CloudKit
  import Combine
  import CombineExpectations
  import XCTest

  @testable import CombineCloudKit

  class CombineCloudKitTests: XCTestCase {
    #if SWIFT_PACKAGE || COCOAPODS
      // Unit tests with mocks
      let container: CCKContainer = MockContainer()
      let database: CCKDatabase = MockDatabase()
      override func setUp() {
        CombineCloudKit.operationFactory = MockOperationFactory(database as! MockDatabase)
      }
    #else
      // Integration tests with CloudKit
      let container: CCKContainer
      let database: CCKDatabase
      override init() {
        let container = CKContainer(
          identifier: "iCloud.dev.hiddenplace.CombineCloudKit.Tests")
        self.container = container
        self.database = container.privateCloudDatabase
        super.init()
      }
    #endif

    func wait<P, R>(
      for selector: (Recorder<P.Output, P.Failure>) -> R,
      from publisher: P,
      timeout: TimeInterval = 1
    ) throws -> R.Output where P: Publisher, R: PublisherExpectation {
      try wait(for: selector(publisher.record()), timeout: timeout)
    }
  }

#endif
