//
//  CKContainerTests.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 4/29/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

#if canImport(CombineExpectations) && canImport(XCTest)

  import CloudKit
  import Combine
  import CombineExpectations
  import XCTest

  @testable import CombineCloudKit

  final class CKContainerTests: CombineCloudKitTests {
    func testAccountStatusIsAvailable() throws {
      let publisher = container.accountStatus()
      let status = try wait(for: \.single, from: publisher)
      XCTAssertEqual(status, .available)
    }

    func testAccountStatusPropagatesErrors() throws {
      let space = DecisionSpace()
      repeat {
        let publisher = MockContainer(space).accountStatus()
        let completion = try wait(for: \.completion, from: publisher)
        if case .failure = completion {
          XCTAssert(space.decidedAffirmatively())
        } else {
          XCTAssertFalse(space.decidedAffirmatively())
        }
      } while space.reset()
    }
  }

#endif
