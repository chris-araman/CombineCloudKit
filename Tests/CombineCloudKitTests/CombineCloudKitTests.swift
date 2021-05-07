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
  lazy var container = CKContainer(identifier: "iCloud.dev.hiddenplace.CombineCloudKit.Tests")

  #if SWIFT_PACKAGE
  override func setUpWithError() throws {
    try super.setUpWithError()

    throw XCTSkip("Tests requiring CloudKit can not be run without app entitlements.")
  }
  #endif

  func waitForLast<P>(from publisher: P, timeout: TimeInterval = 1)
    throws -> P.Output where P: Publisher {
    try XCTUnwrap(try wait(for: publisher.record().last, timeout: timeout))
  }

  func waitForSingle<P>(from publisher: P, timeout: TimeInterval = 1)
    throws -> P.Output where P: Publisher {
    try wait(for: publisher.record().single, timeout: timeout)
  }
}
