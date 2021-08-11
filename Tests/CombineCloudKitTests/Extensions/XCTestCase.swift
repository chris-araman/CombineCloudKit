//
//  XCTestCase.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 8/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import Combine
import CombineExpectations
import XCTest

extension XCTestCase {
  func wait<P, R>(
    for selector: (Recorder<P.Output, P.Failure>) -> R,
    from publisher: P,
    timeout: TimeInterval = 1
  ) throws -> R.Output where P: Publisher, R: PublisherExpectation {
    try wait(for: selector(publisher.record()), timeout: timeout)
  }
}
