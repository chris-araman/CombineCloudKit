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
  let space: DecisionSpace? = nil

  init(_ database: MockDatabase, _ space: DecisionSpace?) {
    self.mockDatabase = database
  }

  public var database: CKDatabase?
}
