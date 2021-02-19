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
    save(records: [record], withConfiguration: configuration)
  }

  public func save(
    records: [CKRecord],
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    let (publishers, operation) = modifyWithoutCancellation(
      recordsToSave: records,
      recordIDsToDelete: nil,
      atomically: isAtomic,
      withConfiguration: configuration
    )
    return publishers.saved.propagateCancellationTo(operation)
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
    delete(recordIDs: [recordID], withConfiguration: configuration)
  }

  public func delete(
    recordIDs: [CKRecord.ID],
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord.ID, Error> {
    let (publishers, operation) = modifyWithoutCancellation(
      recordsToSave: nil,
      recordIDsToDelete: recordIDs,
      atomically: isAtomic,
      withConfiguration: configuration
    )
    return publishers.deleted.propagateCancellationTo(operation)
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
    let (publishers, operation) = modifyWithoutCancellation(
      recordsToSave: recordsToSave,
      recordIDsToDelete: recordIDsToDelete,
      atomically: isAtomic,
      withConfiguration: configuration
    )
    return CCKModifyRecordPublishers(
      progress: publishers.progress.propagateCancellationTo(operation),
      saved: publishers.saved.propagateCancellationTo(operation),
      deleted: publishers.deleted.propagateCancellationTo(operation)
    )
  }

  private func modifyWithoutCancellation(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil,
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> (CCKModifyRecordPublishers, CKModifyRecordsOperation) {
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

    return (
      CCKModifyRecordPublishers(
        progress: progressSubject.propagateCancellationTo(operation),
        saved: savedSubject.propagateCancellationTo(operation),
        deleted: deletedSubject.propagateCancellationTo(operation)
      ),
      operation
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

  public struct CCKFetchRecordPublishers {
    let progress: AnyPublisher<(CKRecord.ID, Double), Error>
    let fetched: AnyPublisher<CKRecord, Error>
  }

  public func fetch(
    recordID: CKRecord.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> CCKFetchRecordPublishers {
    fetch(recordIDs: [recordID], withConfiguration: configuration)
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
      progress: progressSubject.propagateCancellationTo(operation),
      fetched: fetchedSubject.propagateCancellationTo(operation)
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
    }.propagateCancellationTo(operation)
  }

  public func perform(
    ofType recordType: CKRecord.RecordType,
    where predicate: NSPredicate = NSPredicate(value: true),
    orderBy sortDescriptors: [NSSortDescriptor]? = nil,
    inZoneWith zoneID: CKRecordZone.ID? = nil,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    let query = CKQuery(recordType: recordType, predicate: predicate)
    query.sortDescriptors = sortDescriptors
    return perform(
      query: query,
      inZoneWith: zoneID,
      desiredKeys: desiredKeys,
      withConfiguration: configuration
    )
  }

  public func perform(
    query: CKQuery,
    inZoneWith zoneID: CKRecordZone.ID? = nil,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    resultsLimit: Int = CKQueryOperation.maximumResults,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    func continueQuery() {
      if configuration != nil {
        operation.configuration = configuration
      }
      operation.desiredKeys = desiredKeys
      operation.resultsLimit = demand
      operation.zoneID = zoneID
      operation.recordFetchedBlock = { record in
        if demand <= 0 {
          // Ignore any remaining results.
          return
        }

        if demand != CKQueryOperation.maximumResults {
          // Reduce demand.
          demand -= 1
        }

        subject.send(record)
      }
      operation.queryCompletionBlock = { cursor, error in
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
        operation = CKQueryOperation(cursor: cursor)
        continueQuery()
      }

      add(operation)
    }

    let subject = PassthroughSubject<CKRecord, Error>()
    var demand = resultsLimit
    var operation = CKQueryOperation(query: query)
    continueQuery()

    // We don't use propagateCancellationTo(operation) here because
    // the operation we need to cancel may change.
    return subject.handleEvents(receiveCancel: {
      operation.cancel()
    }).eraseToAnyPublisher()
  }
}
