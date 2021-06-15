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
  let error: MockError?

  init(_ error: MockError? = nil) {
    self.error = error
  }

  public func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void) {
    if let error = error {
      completionHandler(.couldNotDetermine, error)
      return
    }

    completionHandler(.available, nil)
  }
}
