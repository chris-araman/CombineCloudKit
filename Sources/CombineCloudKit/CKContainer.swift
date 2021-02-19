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
  public func accountStatus() -> AnyPublisher<CKAccountStatus, Error> {
    Future { promise in
      self.accountStatus { status, error in
        guard error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(status))
      }
    }.eraseToAnyPublisher()
  }
}
