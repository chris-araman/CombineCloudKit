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
  public let finished = XCTestExpectation()

  init(_ publisher: P) {
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
    guard completion == nil else {
      XCTFail("Element received after completion.")
      return .unlimited
    }

    elements.append(input)
    return .unlimited
  }

  func receive(completion: Subscribers.Completion<Failure>) {
    guard self.completion == nil else {
      XCTFail("Another completion received after initial completion.")
      return
    }

    self.completion = completion
    finished.fulfill()
  }
}
