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
  public func save(
    record: CKRecord,
    withHighPriority: Bool = true
  ) -> Future<CKRecord, Error> {
    Future { promise in
      if withHighPriority {
        let operation = CKModifyRecordsOperation(
          recordsToSave: [record], recordIDsToDelete: nil
        )
        operation.modifyRecordsCompletionBlock = { records, _, error in
          guard let record = records?.first, error == nil else {
            promise(.failure(error!))
            return
          }
          
          promise(.success(record))
        }

        self.add(operation)
      } else {
        self.save(record) { record, error in
          guard let record = record, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(record))
        }
      }
    }
  }

  public func save(
    records: [CKRecord],
    atomically isAtomic: Bool = true
  ) -> AnyPublisher<CKRecord, Error> {
    modify(recordsToSave: records, recordIDsToDelete: nil, atomically: isAtomic)
      .map { record, _ in record! }
      .eraseToAnyPublisher()
  }

  public func delete(
    recordID: CKRecord.ID,
    withHighPriority: Bool = true
  ) -> Future<CKRecord.ID, Error> {
    Future { promise in
      if withHighPriority {
        let operation = CKModifyRecordsOperation(
          recordsToSave: nil, recordIDsToDelete: [recordID]
        )
        operation.modifyRecordsCompletionBlock = { _, recordIDs, error in
          guard let recordID = recordIDs?.first, error == nil else {
            promise(.failure(error!))
            return
          }
          
          promise(.success(recordID))
        }

        self.add(operation)
      } else {
        self.delete(withRecordID: recordID) { recordID, error in
          guard let recordID = recordID, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(recordID))
        }
      }
    }
  }

  public func delete(
    recordIDs: [CKRecord.ID],
    atomically isAtomic: Bool = true
  ) -> AnyPublisher<CKRecord.ID, Error> {
    modify(recordsToSave: nil, recordIDsToDelete: recordIDs, atomically: isAtomic)
      .map { _, recordID in recordID! }
      .eraseToAnyPublisher()
  }

  public func modify(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil,
    atomically isAtomic: Bool = true
  ) -> AnyPublisher<(CKRecord?, CKRecord.ID?), Error> {
    let subject = PassthroughSubject<(CKRecord?, CKRecord.ID?), Error>()
    let operation = CKModifyRecordsOperation(
      recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete
    )
    operation.isAtomic = isAtomic
    operation.perRecordCompletionBlock = { record, error in
      guard error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      subject.send((record, nil))
    }
    operation.modifyRecordsCompletionBlock = { _, deletedRecordIDs, error in
      guard error == nil else {
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

  public func fetch(
    withRecordID recordID: CKRecord.ID,
    withHighPriority: Bool = true
  ) -> Future<CKRecord, Error> {
    Future { promise in
      if withHighPriority {
        let operation = CKFetchRecordsOperation(recordIDs: [recordID])
        operation.fetchRecordsCompletionBlock = { records, error in
          guard let record = records?.first?.value, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(record))
        }

        self.add(operation)
      } else {
        self.fetch(withRecordID: recordID) { record, error in
          guard let record = record, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(record))
        }
      }
    }
  }

  public func fetch(
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
        subject.send(completion: .failure(error!))
        return
      }

      subject.send(completion: .finished)
    }
    add(operation)

    return subject.eraseToAnyPublisher()
  }

  public func fetchCurrentUserRecord(
    desiredKeys: [CKRecord.FieldKey]? = nil
  ) -> Future<CKRecord, Error> {
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

  public func query(
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
    let operation = CKQueryOperation(cursor: cursor)
    operation.recordFetchedBlock = subject.send
    operation.queryCompletionBlock = { cursor, error in
      self.onQueryCompletion(subject, cursor, error)
    }

    add(operation)
  }
}
