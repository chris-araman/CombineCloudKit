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
  func publisherFromOperation<Output, Ignored>(
    _ operation: CKDatabaseOperation,
    withConfiguration configuration: CKOperation.Configuration? = nil,
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

  func publisherFromOperation<Output, Ignored>(
    _ operation: CKDatabaseOperation,
    withConfiguration configuration: CKOperation.Configuration? = nil,
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

  func publisherFromOperation<Output, Ignored>(
    _ operation: CKDatabaseOperation,
    withConfiguration configuration: CKOperation.Configuration? = nil,
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
  
  func publisherFromOperation<Output, OutputID, Publishers>(
    _ operation: CKDatabaseOperation,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    setCompletion: (@escaping ([Output]?, [OutputID]?, Error?) -> Void) -> Void,
    initPublishers: (AnyPublisher<Output, Error>, AnyPublisher<OutputID, Error>) -> Publishers
  ) -> Publishers {
    let savedSubject = PassthroughSubject<Output, Error>()
    let deletedSubject = PassthroughSubject<OutputID, Error>()
    if configuration != nil {
      operation.configuration = configuration
    }
    setCompletion { saved, deleted, error in
      guard error == nil else {
        savedSubject.send(completion: .failure(error!))
        deletedSubject.send(completion: .failure(error!))
        return
      }

      if let saved = saved {
        for output in saved {
          savedSubject.send(output)
        }
      }

      if let deleted = deleted {
        for outputID in deleted {
          deletedSubject.send(outputID)
        }
      }

      savedSubject.send(completion: .finished)
      deletedSubject.send(completion: .finished)
    }

    add(operation)

    return initPublishers(
      savedSubject.propagateCancellationTo(operation),
      deletedSubject.propagateCancellationTo(operation)
    )
  }
}
