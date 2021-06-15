//
//  ProgressTests.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/14/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

#if canImport(XCTest)

  import XCTest

  @testable import CombineCloudKit

  final class ProgressTests: XCTestCase {
    func testCompleteIsNotLessThanItself() {
      XCTAssertFalse(Progress.complete < .complete)
    }

    func testIncompleteWithSameProgressIsNotLessThanItself() {
      XCTAssertFalse(Progress(percent: 50) < Progress(percent: 50))
    }

    func testCompleteIsNotLessThanIncomplete() {
      XCTAssertFalse(Progress.complete < .incomplete(percent: 50))
    }

    func testIncompleteWithLessProgressIsLessThanItself() {
      XCTAssertLessThan(Progress(percent: 40), Progress(percent: 50))
    }

    func testIncompleteIsLessThanComplete() {
      XCTAssertLessThan(Progress(percent: 50), .complete)
    }

    func testLessThanZeroPercentEqualsZeroPercent() {
      XCTAssertEqual(Progress(rawValue: -1), .incomplete(percent: 0))
    }

    func testMoreThanOneHundredPercentEqualsComplete() {
      XCTAssertEqual(Progress(rawValue: 101), .complete)
    }

    func testOneHundredPercentEqualsComplete() {
      XCTAssertEqual(Progress(percent: 100), .complete)
    }
  }

#endif
