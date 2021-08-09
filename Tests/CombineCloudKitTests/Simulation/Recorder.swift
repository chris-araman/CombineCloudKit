//
//  Recorder.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 8/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import Combine
import XCTest

class Recorder<P>: Subscriber where P: Publisher {
  typealias Input = P.Output
  typealias Failure = P.Failure

  var subscription: Subscription?

  public var elements = [Input]()
  public var completion: Subscribers.Completion<Failure>?
  public let finished: XCTestExpectation

  init(_ publisher: P, _ finished: XCTestExpectation) {
    self.finished = finished
    publisher.receive(subscriber: self)
  }

  deinit {
    subscription?.cancel()
  }

  func receive(subscription: Subscription) {
    self.subscription = subscription
    subscription.request(.unlimited)
  }

  func receive(_ input: Input) -> Subscribers.Demand {
    if completion != nil {
      XCTFail("Element received after completion.")
    }

    elements.append(input)
    return .unlimited
  }

  func receive(completion: Subscribers.Completion<Failure>) {
    if self.completion != nil {
      XCTFail("Another completion received after initial completion.")
    }

    self.completion = completion
    finished.fulfill()
  }
}
