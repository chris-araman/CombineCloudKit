//
//  CKContainer.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/18/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

internal func publisherFrom<Output>(
  method: @escaping (@escaping (Output, Error?) -> Void) -> Void
) -> AnyPublisher<Output, Error> {
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

internal func publisherFrom<Output>(
  method: @escaping (@escaping ([Output]?, Error?) -> Void) -> Void
) -> AnyPublisher<Output, Error> {
  let subject = PassthroughSubject<Output, Error>()

  method { outputs, error in
    guard let outputs = outputs, error == nil else {
      subject.send(completion: .failure(error!))
      return
    }

    for output in outputs {
      subject.send(output)
    }

    subject.send(completion: .finished)
  }

  return subject.eraseToAnyPublisher()
}

internal func publisherFrom<Input, Output>(
  method: @escaping (Input, @escaping (Output?, Error?) -> Void) -> Void,
  with input: Input
) -> AnyPublisher<Output, Error> {
  Future { promise in
    method(input) { output, error in
      guard let output = output, error == nil else {
        promise(.failure(error!))
        return
      }

      promise(.success(output))
    }
  }.eraseToAnyPublisher()
}
