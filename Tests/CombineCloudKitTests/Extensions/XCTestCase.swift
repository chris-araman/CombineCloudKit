//
//  XCTestCase.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 8/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import Combine
import XCTest

extension XCTestCase {
  func waitForFinished<P>(
    from publisher: P,
    timeout: TimeInterval = 1
  ) throws where P: Publisher {
    let recorder = Recorder(publisher)
    wait(for: [recorder.finished], timeout: timeout)
    if case .failure(let error) = recorder.completion {
      throw error
    }
  }

  func waitForElements<P>(
    from publisher: P,
    timeout: TimeInterval = 1
  ) throws -> [P.Output] where P: Publisher {
    let recorder = Recorder(publisher)
    wait(for: [recorder.finished], timeout: timeout)
    return recorder.elements
  }

  func waitForSingle<P>(
    from publisher: P,
    timeout: TimeInterval = 1
  ) throws -> P.Output where P: Publisher {
    let elements = try waitForElements(from: publisher, timeout: timeout)
    guard elements.count == 1 else {
      throw RecorderError.UnexpectedElementCount
    }

    return elements[0]
  }
}
