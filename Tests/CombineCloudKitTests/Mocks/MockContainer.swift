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
  var space: DecisionSpace?

  init(_ space: DecisionSpace? = nil) {
    self.space = space
  }

  public func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void) {
    if let space = space, space.decide() {
      completionHandler(.couldNotDetermine, MockError.simulated)
      return
    }

    completionHandler(.available, nil)
  }
}
