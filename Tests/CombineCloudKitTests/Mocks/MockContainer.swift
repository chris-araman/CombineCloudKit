//
//  MockContainer.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import CombineCloudKit

public class MockContainer: CCKContainer {
  let space: DecisionSpace?

  init(_ space: DecisionSpace? = nil) {
    self.space = space
  }

  public func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void) {
    if let space = space, space.decide() {
      completionHandler(.couldNotDetermine, MockError.doesNotExist)
      return
    }

    completionHandler(.available, nil)
  }
}
