//
//  CKRecord.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/16/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension CKDatabase {
  public func saveAtBackgroundPriority(record: CKRecord) -> Future<CKRecord, Error> {
    Future { promise in
      self.save(record) { record, error in
        guard let record = record, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(record))
      }
    }
  }

  public func save(
    record: CKRecord,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    let operation = CKModifyRecordsOperation(
      recordsToSave: [record], recordIDsToDelete: nil
    )
    if configuration != nil {
      operation.configuration = configuration
    }

    return Future { promise in
      operation.modifyRecordsCompletionBlock = { records, _, error in
        guard let record = records?.first, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(record))
      }

      self.add(operation)
    }.handleEvents(receiveCancel: {
      operation.cancel()
    }).eraseToAnyPublisher()
  }

  public func save(
    records: [CKRecord],
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    modify(
      recordsToSave: records,
      recordIDsToDelete: nil,
      atomically: isAtomic,
      withConfiguration: configuration
    ).saved
  }

  public func deleteAtBackgroundPriority(recordID: CKRecord.ID) -> Future<CKRecord.ID, Error> {
    Future { promise in
      self.delete(withRecordID: recordID) { recordID, error in
        guard let recordID = recordID, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(recordID))
      }
    }
  }

  public func delete(
    recordID: CKRecord.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord.ID, Error> {
    let operation = CKModifyRecordsOperation(
      recordsToSave: nil, recordIDsToDelete: [recordID]
    )
    if configuration != nil {
      operation.configuration = configuration
    }

    return Future { promise in
      operation.modifyRecordsCompletionBlock = { _, recordIDs, error in
        guard let recordID = recordIDs?.first, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(recordID))
      }

      self.add(operation)
    }.handleEvents(receiveCancel: {
      operation.cancel()
    }).eraseToAnyPublisher()
  }

  public func delete(
    recordIDs: [CKRecord.ID],
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord.ID, Error> {
    modify(
      recordsToSave: nil,
      recordIDsToDelete: recordIDs,
      atomically: isAtomic,
      withConfiguration: configuration
    ).deleted
  }

  public struct CCKModifyRecordPublishers {
    let progress: AnyPublisher<(CKRecord, Double), Error>
    let saved: AnyPublisher<CKRecord, Error>
    let deleted: AnyPublisher<CKRecord.ID, Error>
  }

  public func modify(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil,
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> CCKModifyRecordPublishers {
    let progressSubject = PassthroughSubject<(CKRecord, Double), Error>()
    let savedSubject = PassthroughSubject<CKRecord, Error>()
    let deletedSubject = PassthroughSubject<CKRecord.ID, Error>()
    let operation = CKModifyRecordsOperation(
      recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete
    )
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.isAtomic = isAtomic
    operation.perRecordProgressBlock = { record, progress in
      progressSubject.send((record, progress))
    }
    operation.perRecordCompletionBlock = { record, error in
      guard error == nil else {
        savedSubject.send(completion: .failure(error!))
        return
      }

      savedSubject.send(record)
    }
    operation.modifyRecordsCompletionBlock = { _, deletedRecordIDs, error in
      guard error == nil else {
        progressSubject.send(completion: .failure(error!))
        savedSubject.send(completion: .failure(error!))
        deletedSubject.send(completion: .failure(error!))
        return
      }

      if let deletedRecordIDs = deletedRecordIDs {
        for recordID in deletedRecordIDs {
          deletedSubject.send(recordID)
        }
      }

      progressSubject.send(completion: .finished)
      savedSubject.send(completion: .finished)
      deletedSubject.send(completion: .finished)
    }

    add(operation)

    return CCKModifyRecordPublishers(
      progress: progressSubject.eraseToAnyPublisher(),
      saved: savedSubject.eraseToAnyPublisher(),
      deleted: deletedSubject.eraseToAnyPublisher()
    )
  }

  public func fetchAtBackgroundPriority(
    withRecordID recordID: CKRecord.ID
  ) -> Future<CKRecord, Error> {
    Future { promise in
      self.fetch(withRecordID: recordID) { record, error in
        guard let record = record, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(record))
      }
    }
  }

  public func fetch(
    withRecordID recordID: CKRecord.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    let operation = CKFetchRecordsOperation(recordIDs: [recordID])
    if configuration != nil {
      operation.configuration = configuration
    }

    return Future { promise in
      operation.fetchRecordsCompletionBlock = { records, error in
        guard let record = records?.first?.value, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(record))
      }

      self.add(operation)
    }.handleEvents(receiveCancel: {
      operation.cancel()
    }).eraseToAnyPublisher()
  }

  public struct CCKFetchRecordPublishers {
    let progress: AnyPublisher<(CKRecord.ID, Double), Error>
    let fetched: AnyPublisher<CKRecord, Error>
  }

  public func fetch(
    recordIDs: [CKRecord.ID],
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> CCKFetchRecordPublishers {
    let progressSubject = PassthroughSubject<(CKRecord.ID, Double), Error>()
    let fetchedSubject = PassthroughSubject<CKRecord, Error>()
    let operation = CKFetchRecordsOperation(recordIDs: recordIDs)
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.desiredKeys = desiredKeys
    operation.perRecordProgressBlock = { recordID, progress in
      progressSubject.send((recordID, progress))
    }
    operation.perRecordCompletionBlock = { record, _, error in
      guard let record = record, error == nil else {
        progressSubject.send(completion: .failure(error!))
        fetchedSubject.send(completion: .failure(error!))
        return
      }

      fetchedSubject.send(record)
    }
    operation.fetchRecordsCompletionBlock = { _, error in
      guard error == nil else {
        progressSubject.send(completion: .failure(error!))
        fetchedSubject.send(completion: .failure(error!))
        return
      }

      progressSubject.send(completion: .finished)
      fetchedSubject.send(completion: .finished)
    }
    add(operation)

    return CCKFetchRecordPublishers(
      progress: progressSubject.eraseToAnyPublisher(),
      fetched: fetchedSubject.eraseToAnyPublisher()
    )
  }

  public func fetchCurrentUserRecord(
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    let operation = CKFetchRecordsOperation.fetchCurrentUserRecordOperation()
    if configuration != nil {
      operation.configuration = configuration
    }

    return Future { promise in
      operation.desiredKeys = desiredKeys
      operation.fetchRecordsCompletionBlock = { records, error in
        guard let record = records?.first?.value, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(record))
      }

      self.add(operation)
    }.handleEvents(receiveCancel: {
      operation.cancel()
    }).eraseToAnyPublisher()
  }

  public func perform(
    ofType recordType: CKRecord.RecordType,
    where predicate: NSPredicate = NSPredicate(value: true),
    orderBy sortDescriptors: [NSSortDescriptor]? = nil,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    let query = CKQuery(recordType: recordType, predicate: predicate)
    query.sortDescriptors = sortDescriptors
    return perform(
      query: query,
      desiredKeys: desiredKeys,
      withConfiguration: configuration)
  }

  public func perform(
    query: CKQuery,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    func onQueryCompletion(cursor: CKQueryOperation.Cursor?, error: Error?) {
      guard error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      guard let cursor = cursor else {
        // We've fetched all the results.
        subject.send(completion: .finished)
        return
      }

      // Fetch the next page of results.
      configureAndAdd(CKQueryOperation(cursor: cursor))
    }

    func configureAndAdd(_ operation: CKQueryOperation) {
      if configuration != nil {
        operation.configuration = configuration
      }
      operation.desiredKeys = desiredKeys
      operation.recordFetchedBlock = subject.send
      operation.queryCompletionBlock = onQueryCompletion
      add(operation)
    }

    let subject = PassthroughSubject<CKRecord, Error>()
    configureAndAdd(CKQueryOperation(query: query))
    return subject.eraseToAnyPublisher()
  }
}
