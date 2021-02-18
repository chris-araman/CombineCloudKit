import CloudKit
import Combine
import CombineExpectations
import XCTest

@testable import CombineCloudKit

final class CKDatabaseTests: XCTestCase {
  func testSendSecondFailure() throws {
    let subject = PassthroughSubject<Void, Error>()
    let recorder = subject.record()
    subject.send(completion: .failure(CKError(.operationCancelled)))
    subject.send(completion: .failure(CKError(.internalError)))
    switch try wait(for: recorder.completion, timeout: 1) {
    case .failure(let error):
      guard let error = error as? CKError, error.errorCode == CKError.operationCancelled.rawValue
      else {
        XCTFail("Recorder did not receive CKError.operationCancelled.")
        return
      }
    case .finished:
      XCTFail("Recorder did not receive a failure.")
    }
  }
}
