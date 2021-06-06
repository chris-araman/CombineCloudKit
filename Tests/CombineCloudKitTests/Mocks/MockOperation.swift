//
//  MockOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import CombineCloudKit

public class MockOperation: CCKOperation {
  public var configuration: CKOperation.Configuration!

  open func start() {
    fatalError("MockOperation start not implemented for \(String(describing: type(of: self))).")
  }

  public func cancel() {
    // TODO:
  }
}
