//
//  CombineCloudKitTests.swift
//
//
//  Created by Chris Araman on 5/7/21.
//

import CloudKit
import Combine
import CombineExpectations
import XCTest

@testable import CombineCloudKit

class CombineCloudKitTests: XCTestCase {
  let container = CKContainer(identifier: "iCloud.dev.hiddenplace.CombineCloudKit.Tests")

  func waitForLast<P>(from publisher: P, timeout: TimeInterval = 1)
    throws -> P.Output where P: Publisher {
    try XCTUnwrap(try wait(for: publisher.record().last, timeout: timeout))
  }

  func waitForSingle<P>(from publisher: P, timeout: TimeInterval = 1)
    throws -> P.Output where P: Publisher {
    try wait(for: publisher.record().single, timeout: timeout)
  }
}
