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
  public final func saveAtBackgroundPriority(record: CKRecord) -> AnyPublisher<CKRecord, Error> {
    publisherFrom(save, with: record)
  }

  public final func save(
    record: CKRecord,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    save(records: [record], withConfiguration: configuration)
  }

  public final func save(
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

  public final func deleteAtBackgroundPriority(recordID: CKRecord.ID)
    -> AnyPublisher<CKRecord.ID, Error>
  {
    publisherFrom(delete, with: recordID)
  }

  public final func delete(
    recordID: CKRecord.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord.ID, Error> {
    delete(recordIDs: [recordID], withConfiguration: configuration)
  }

  public final func delete(
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

  public struct CCKModifyRecordsPublishers {
    let progress: AnyPublisher<(CKRecord, Double), Error>
    let saved: AnyPublisher<CKRecord, Error>
    let deleted: AnyPublisher<CKRecord.ID, Error>
  }

  public final func modify(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil,
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> CCKModifyRecordsPublishers {
    let (publishers, operation) = modifyWithoutCancellation(
      recordsToSave: recordsToSave,
      recordIDsToDelete: recordIDsToDelete,
      atomically: isAtomic,
      withConfiguration: configuration
    )
    return CCKModifyRecordsPublishers(
      progress: publishers.progress.propagateCancellationTo(operation),
      saved: publishers.saved.propagateCancellationTo(operation),
      deleted: publishers.deleted.propagateCancellationTo(operation)
    )
  }

  private final func modifyWithoutCancellation(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil,
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> (CCKModifyRecordsPublishers, CKModifyRecordsOperation) {
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
      CCKModifyRecordsPublishers(
        progress: progressSubject.propagateCancellationTo(operation),
        saved: savedSubject.propagateCancellationTo(operation),
        deleted: deletedSubject.propagateCancellationTo(operation)
      ),
      operation
    )
  }

  public final func fetchAtBackgroundPriority(
    withRecordID recordID: CKRecord.ID
  ) -> AnyPublisher<CKRecord, Error> {
    publisherFrom(fetch, with: recordID)
  }

  public struct CCKFetchRecordsPublishers {
    let progress: AnyPublisher<(CKRecord.ID, Double), Error>
    let fetched: AnyPublisher<CKRecord, Error>
  }

  public final func fetch(
    recordID: CKRecord.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> CCKFetchRecordsPublishers {
    fetch(recordIDs: [recordID], withConfiguration: configuration)
  }

  public final func fetch(
    recordIDs: [CKRecord.ID],
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> CCKFetchRecordsPublishers {
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

    return CCKFetchRecordsPublishers(
      progress: progressSubject.propagateCancellationTo(operation),
      fetched: fetchedSubject.propagateCancellationTo(operation)
    )
  }

  public final func fetchCurrentUserRecord(
    desiredKeys _: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    let operation = CKFetchRecordsOperation.fetchCurrentUserRecordOperation()
    return publisherFrom(operation, configuration) { completion in
      operation.fetchRecordsCompletionBlock = completion
    }
  }

  public final func performQuery(
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

  public final func perform(
    query: CKQuery,
    inZoneWith zoneID: CKRecordZone.ID? = nil,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    QueryPublisher(database: self, query, zoneID, desiredKeys, configuration).eraseToAnyPublisher()
  }
}
