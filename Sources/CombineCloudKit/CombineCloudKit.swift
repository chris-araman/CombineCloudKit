//
//  CKContainer.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/18/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

internal func publisherFrom<T>(
  _ method: @escaping (@escaping (T, Error?) -> Void) -> Void
) -> AnyPublisher<T, Error> {
  Future { promise in
    method { item, error in
      guard error == nil else {
        promise(.failure(error!))
        return
      }

      promise(.success(item))
    }
  }.eraseToAnyPublisher()
}

internal func publisherFrom<T, U>(
  _ method: @escaping (T, @escaping (U?, Error?) -> Void) -> Void,
  _ item: T
) -> AnyPublisher<U, Error> {
  Future { promise in
    method(item) { item, error in
      guard let item = item, error == nil else {
        promise(.failure(error!))
        return
      }

      promise(.success(item))
    }
  }.eraseToAnyPublisher()
}
