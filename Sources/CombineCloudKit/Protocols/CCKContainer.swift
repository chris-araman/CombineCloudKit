//
//  CCKContainer.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension CKContainer: CCKContainer {
}

protocol CCKContainer {
  func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void)
}

extension CCKContainer {
  private func publisherFrom<Output>(
    _ method: @escaping (@escaping (Output, Error?) -> Void) -> Void
  ) -> AnyPublisher<Output, Error> {
    Deferred {
      Future { promise in
        method { item, error in
          guard error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(item))
        }
      }
    }.eraseToAnyPublisher()
  }

  /// Determines whether the system can access the user’s iCloud account.
  ///
  /// - Returns: A `Publisher` that emits a single `CKAccountStatus`, or an error if CombineCloudKit is unable to
  /// determine the account status.
  /// - SeeAlso: [`accountStatus`](https://developer.apple.com/documentation/cloudkit/ckcontainer/1399180-accountstatus)
  public func accountStatus() -> AnyPublisher<CKAccountStatus, Error> {
    publisherFrom(accountStatus)
  }
}
