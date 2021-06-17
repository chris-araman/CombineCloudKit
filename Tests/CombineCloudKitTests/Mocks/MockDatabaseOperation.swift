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
  let space: DecisionSpace?

  init(_ database: MockDatabase, _ space: DecisionSpace?) {
    self.mockDatabase = database
    self.space = space
  }

  public var database: CKDatabase?
}
