//
//  CombineCloudKitTests.swift
//
//
//  Created by Chris Araman on 5/7/21.
//

#if canImport(CombineExpectations) && canImport(XCTest)

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

    func wait<P, R>(
      for selector: (Recorder<P.Output, P.Failure>) -> R,
      from publisher: P,
      timeout: TimeInterval = 1
    ) throws -> R.Output where P: Publisher, R: PublisherExpectation {
      try wait(for: selector(publisher.record()), timeout: timeout)
    }
  }

#endif
