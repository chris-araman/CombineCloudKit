//
//  CKContainerTests.swift
//
//
//  Created by Chris Araman on 4/29/21.
//

import CloudKit
import Combine
import CombineExpectations
import XCTest

@testable import CombineCloudKit

final class CKContainerTests: CombineCloudKitTests {
  func testAccountStatusIsAvailable() throws {
    let publisher = container.accountStatus()
    let status = try waitForSingle(from: publisher)
    XCTAssertEqual(status, .available)
  }
}
