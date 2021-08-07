//
//  XCTestCase.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 8/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import Combine
import XCTest

enum PublisherTestError: Error {
  case unexpectedElementCount
}

extension XCTestCase {
  func waitForFinished<P>(
    from publisher: P,
    timeout: TimeInterval = 1
  ) throws where P: Publisher {
    _ = try waitFor(publisher, timeout)
  }

  func waitForElements<P>(
    from publisher: P,
    timeout: TimeInterval = 1
  ) throws -> [P.Output] where P: Publisher {
    try waitFor(publisher, timeout).elements
  }

  func waitForSingle<P>(
    from publisher: P,
    timeout: TimeInterval = 1
  ) throws -> P.Output where P: Publisher {
    let elements = try waitFor(publisher, timeout).elements
    guard elements.count == 1 else {
      throw PublisherTestError.unexpectedElementCount
    }

    return elements[0]
  }

  private func waitFor<P>(
    _ publisher: P,
    _ timeout: TimeInterval
  ) throws -> Recorder<P> where P: Publisher {
    let recorder = Recorder(publisher)
    wait(for: [recorder.finished], timeout: timeout)
    if case .failure(let error) = recorder.completion {
      throw error
    }

    return recorder
  }
}
