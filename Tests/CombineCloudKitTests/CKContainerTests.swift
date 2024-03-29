//
//  CKContainerTests.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 4/29/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine
import XCTest

@testable import CombineCloudKit

final class CKContainerTests: CombineCloudKitTests {
  func testAccountStatusIsAvailable() throws {
    let publisher = container.accountStatus()
    let status = try waitForSingle(from: publisher)
    XCTAssertEqual(status, .available)
  }
}
