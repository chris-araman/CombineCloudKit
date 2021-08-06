//
//  CombineCloudKitTests.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 5/7/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
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
}
