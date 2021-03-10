//
//  CKContainer.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/18/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension CKContainer {
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
  public final func accountStatus() -> AnyPublisher<CKAccountStatus, Error> {
    publisherFrom(accountStatus)
  }
}
