//
//  CKDatabase.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/16/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension CKDatabase {
  func save(record: CKRecord) -> Future<CKRecord, Error> {
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

  func save(
    records: [CKRecord],
    atomically isAtomic: Bool = true
  ) -> AnyPublisher<CKRecord, Error> {
    modify(recordsToSave: records, recordIDsToDelete: nil, atomically: isAtomic)
      .map { record, _ in record! }
      .eraseToAnyPublisher()
  }

  func delete(recordID: CKRecord.ID) -> Future<CKRecord.ID, Error> {
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

  func delete(
    recordIDs: [CKRecord.ID],
    atomically isAtomic: Bool = true
  ) -> AnyPublisher<CKRecord.ID, Error> {
    modify(recordsToSave: nil, recordIDsToDelete: recordIDs, atomically: isAtomic)
      .map { _, recordID in recordID! }
      .eraseToAnyPublisher()
  }

  func modify(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil,
    atomically isAtomic: Bool = true
  ) -> AnyPublisher<(CKRecord?, CKRecord.ID?), Error> {
    let subject = PassthroughSubject<(CKRecord?, CKRecord.ID?), Error>()
    let operation = CKModifyRecordsOperation(
      recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete
    )
    operation.isAtomic = isAtomic
    operation.savePolicy = .changedKeys
    operation.perRecordCompletionBlock = { record, error in
      guard error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      subject.send((record, nil))
    }
    operation.modifyRecordsCompletionBlock = { _, deletedRecordIDs, error in
      guard error == nil else {
        // TODO: Might this send a second failure completion? What happens if it does?
        subject.send(completion: .failure(error!))
        return
      }

      if let deletedRecordIDs = deletedRecordIDs {
        for recordID in deletedRecordIDs {
          subject.send((nil, recordID))
        }
      }

      subject.send(completion: .finished)
    }

    add(operation)
    return subject.eraseToAnyPublisher()
  }

  func fetch(
    recordIDs: [CKRecord.ID],
    desiredKeys: [CKRecord.FieldKey]? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    let subject = PassthroughSubject<CKRecord, Error>()
    let operation = CKFetchRecordsOperation(recordIDs: recordIDs)
    operation.desiredKeys = desiredKeys
    operation.perRecordCompletionBlock = { record, _, error in
      guard let record = record, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      subject.send(record)
    }
    operation.fetchRecordsCompletionBlock = { _, error in
      guard error == nil else {
        // TODO: Might this send a second failure completion? What happens if it does?
        subject.send(completion: .failure(error!))
        return
      }

      subject.send(completion: .finished)
    }
    add(operation)

    return subject.eraseToAnyPublisher()
  }

  func fetchCurrentUserRecord(desiredKeys: [CKRecord.FieldKey]? = nil) -> Future<CKRecord, Error> {
    Future { promise in
      let operation = CKFetchRecordsOperation.fetchCurrentUserRecordOperation()
      operation.desiredKeys = desiredKeys
      operation.fetchRecordsCompletionBlock = { records, error in
        guard let record = records?.first?.value, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(record))
      }

      self.add(operation)
    }
  }

  func query(
    ofType recordType: CKRecord.RecordType,
    where predicate: NSPredicate = NSPredicate(value: true),
    desiredKeys: [CKRecord.FieldKey]? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    let subject = PassthroughSubject<CKRecord, Error>()
    let operation = CKQueryOperation(query: CKQuery(recordType: recordType, predicate: predicate))
    operation.desiredKeys = desiredKeys
    operation.recordFetchedBlock = subject.send
    operation.queryCompletionBlock = { cursor, error in
      self.onQueryCompletion(subject, cursor, error)
    }

    add(operation)
    return subject.eraseToAnyPublisher()
  }

  private func onQueryCompletion(
    _ subject: PassthroughSubject<CKRecord, Error>,
    _ cursor: CKQueryOperation.Cursor?,
    _ error: Error?
  ) {
    if let error = error {
      subject.send(completion: .failure(error))
      return
    }

    guard let cursor = cursor else {
      // We've fetched all the results.
      subject.send(completion: .finished)
      return
    }

    // Fetch the next page of results.
    let operation = CKQueryOperation(cursor: cursor)
    operation.recordFetchedBlock = subject.send
    operation.queryCompletionBlock = { cursor, error in
      self.onQueryCompletion(subject, cursor, error)
    }

    add(operation)
  }
}
