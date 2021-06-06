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
  public func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void) {
    // TODO: Simulate failures.
    completionHandler(.available, nil)
  }
}
