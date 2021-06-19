//
//  CCKContainer.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

/// An extension that declares [`CKContainer`](https://developer.apple.com/documentation/cloudkit/ckcontainer)
/// conforms to the ``CCKContainer`` protocol provided by CombineCloudKit.
///
/// - SeeAlso:[`CloudKit`](https://developer.apple.com/documentation/cloudkit)
/// - SeeAlso:[`Combine`](https://developer.apple.com/documentation/combine)
extension CKContainer: CCKContainer {
}

/// A protocol used to abstract a [`CKContainer`](https://developer.apple.com/documentation/cloudkit/ckcontainer).
///
/// Invoke the extension methods on your [`CKContainer`](https://developer.apple.com/documentation/cloudkit/ckcontainer)
/// instances in order to create [`Publishers`](https://developer.apple.com/documentation/combine/publishers).
///
/// - SeeAlso: [`CloudKit`](https://developer.apple.com/documentation/cloudkit)
/// - SeeAlso: [`Combine`](https://developer.apple.com/documentation/combine)
public protocol CCKContainer {
  /// Implemented by `CKContainer`.
  ///
  /// - SeeAlso: [`accountStatus`](https://developer.apple.com/documentation/cloudkit/ckcontainer/1399180-accountstatus)
  func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void)
}

extension CCKContainer {
  private func publisherFrom<Output>(
    _ method: @escaping (@escaping (Output, Error?) -> Void) -> Void
  ) -> AnyPublisher<Output, Error> {
    Deferred {
      Future { promise in
        DispatchQueue.main.async {
          method { item, error in
            guard error == nil else {
              promise(.failure(error!))
              return
            }

            promise(.success(item))
          }
        }
      }
    }.eraseToAnyPublisher()
  }

  /// Determines whether the system can access the user’s iCloud account.
  ///
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits a single
  /// [`CKAccountStatus`](https://developer.apple.com/documentation/cloudkit/ckaccountstatus), or an error if
  /// CombineCloudKit is unable to determine the account status.
  /// The publisher ignores requests for cooperative cancellation.
  /// - SeeAlso: [`accountStatus`](https://developer.apple.com/documentation/cloudkit/ckcontainer/1399180-accountstatus)
  public func accountStatus() -> AnyPublisher<CKAccountStatus, Error> {
    publisherFrom(accountStatus)
  }
}
