//
//  CKDatabase.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/19/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension CKDatabase {
  func publisherFrom<Output>(
    _ method: @escaping (@escaping ([Output]?, Error?) -> Void) -> Void
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

  func publisherFrom<Input, Output>(
    _ method: @escaping (Input, @escaping (Output?, Error?) -> Void) -> Void,
    with input: Input
  ) -> AnyPublisher<Output, Error> {
    Deferred {
      Future { promise in
        method(input) { output, error in
          guard let output = output, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(output))
        }
      }
    }.eraseToAnyPublisher()
  }

  func publisherFrom<Output, Ignored>(
    _ operation: CKDatabaseOperation,
    _ configuration: CKOperation.Configuration? = nil,
    _ setCompletion: (@escaping ([Ignored: Output]?, Error?) -> Void) -> Void
  ) -> AnyPublisher<Output, Error> {
    let subject = PassthroughSubject<Output, Error>()
    if configuration != nil {
      operation.configuration = configuration
    }
    setCompletion { outputs, error in
      guard let outputs = outputs, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for output in outputs.values {
        subject.send(output)
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
  }

  func publisherFrom<Output, Ignored>(
    _ operation: CKDatabaseOperation,
    _ configuration: CKOperation.Configuration? = nil,
    _ setCompletion: (@escaping ([Output]?, Ignored, Error?) -> Void) -> Void
  ) -> AnyPublisher<Output, Error> {
    let subject = PassthroughSubject<Output, Error>()
    if configuration != nil {
      operation.configuration = configuration
    }
    setCompletion { outputs, _, error in
      guard let outputs = outputs, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for output in outputs {
        subject.send(output)
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
  }

  func publisherFrom<Output, Ignored>(
    _ operation: CKDatabaseOperation,
    _ configuration: CKOperation.Configuration? = nil,
    _ setCompletion: (@escaping (Ignored, [Output]?, Error?) -> Void) -> Void
  ) -> AnyPublisher<Output, Error> {
    let subject = PassthroughSubject<Output, Error>()
    if configuration != nil {
      operation.configuration = configuration
    }
    setCompletion { _, outputs, error in
      guard let outputs = outputs, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for output in outputs {
        subject.send(output)
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
  }

  func publisherFrom<Output, OutputID>(
    _ operation: CKDatabaseOperation,
    _ configuration: CKOperation.Configuration? = nil,
    setCompletion: (@escaping ([Output]?, [OutputID]?, Error?) -> Void) -> Void
  ) -> AnyPublisher<(Output?, OutputID?), Error> {
    let subject = PassthroughSubject<(Output?, OutputID?), Error>()
    if configuration != nil {
      operation.configuration = configuration
    }
    setCompletion { saved, deleted, error in
      guard error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      if let saved = saved {
        for output in saved {
          subject.send((output, nil))
        }
      }

      if let deleted = deleted {
        for outputID in deleted {
          subject.send((nil, outputID))
        }
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
  }
}
