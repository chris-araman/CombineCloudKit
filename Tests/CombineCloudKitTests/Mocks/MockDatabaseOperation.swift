//
//  MockDatabaseOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import CombineCloudKit

public class MockDatabaseOperation: MockOperation, CCKDatabaseOperation {
  let mockDatabase: MockDatabase

  init(_ database: MockDatabase) {
    self.mockDatabase = database
  }
}
