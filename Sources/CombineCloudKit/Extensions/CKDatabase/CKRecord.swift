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
  /// Saves a single record.
  ///
  /// - Parameters:
  ///   - record: The record to save to the database.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Note: CombineCloudKit executes the save with a low priority. Use this method when you don’t require the save to
  /// happen immediately.
  /// - Returns: A `Publisher` that emits the saved `CKRecord`, or an error if CombineCloudKit can't save it.
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449114-save)
  public final func saveAtBackgroundPriority(record: CKRecord) -> AnyPublisher<CKRecord, Error> {
    publisherFrom(save, with: record)
  }

  /// Saves a single record.
  ///
  /// - Parameters:
  ///   - record: The record to save to the database.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A `Publisher` that emits progress of the saved `CKRecord`, or an error if CombineCloudKit can't save it.
  ///   Progress is a `Double` where `0.0` indicates no progress, and `1.0` indicates completion.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public final func save(
    record: CKRecord,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<(CKRecord, Double), Error> {
    save(records: [record], withConfiguration: configuration)
  }

  /// Saves multiple records.
  ///
  /// - Parameters:
  ///   - records: The records to save to the database.
  ///   - isAtomic: A Boolean value that indicates whether the entire operation fails when CloudKit can’t save one or
  ///     more records in a record zone.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A `Publisher` that emits progress of the saved `CKRecord`s, or an error if CombineCloudKit can't save them.
  ///   Progress is a `Double` where `0.0` indicates no progress, and `1.0` indicates completion.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public final func save(
    records: [CKRecord],
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<(CKRecord, Double), Error> {
    return modify(
      recordsToSave: records,
      recordIDsToDelete: nil,
      atomically: isAtomic,
      withConfiguration: configuration
    ).compactMap { (progress, _) in
      progress
    }.eraseToAnyPublisher()
  }

  /// Deletes a single record.
  ///
  /// - Parameters:
  ///   - recordID: The ID of the record to delete permanently from the database.
  /// - Note: CombineCloudKit executes the delete with a low priority. Use this method when you don’t require the delete
  /// to happen immediately.
  /// - Returns: A `Publisher` that emits the saved `CKRecord.ID`, or an error if CombineCloudKit can't save it.
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449122-delete)
  public final func deleteAtBackgroundPriority(recordID: CKRecord.ID)
    -> AnyPublisher<CKRecord.ID, Error>
  {
    publisherFrom(delete, with: recordID)
  }

  /// Deletes a single record.
  ///
  /// - Parameters:
  ///   - recordID: The ID of the record to delete permanently from the database.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A `Publisher` that emits the deleted `CKRecord.ID`, or an error if CombineCloudKit can't delete
  /// it.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public final func delete(
    recordID: CKRecord.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord.ID, Error> {
    delete(recordIDs: [recordID], withConfiguration: configuration)
  }

  /// Deletes multiple records.
  ///
  /// - Parameters:
  ///   - recordIDs: The IDs of the records to delete permanently from the database.
  ///   - isAtomic: A Boolean value that indicates whether the entire operation fails when CloudKit can’t delete one or
  ///     more records in a record zone.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A `Publisher` that emits the deleted `CKRecord.ID`s, or an error if CombineCloudKit can't delete
  /// them.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public final func delete(
    recordIDs: [CKRecord.ID],
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord.ID, Error> {
    return modify(
      recordsToSave: nil,
      recordIDsToDelete: recordIDs,
      atomically: isAtomic,
      withConfiguration: configuration
    ).compactMap { (_, deleted) in
      deleted
    }.eraseToAnyPublisher()
  }

  /// Modifies one or more records.
  ///
  /// - Parameters:
  ///   - recordsToSave: The records to save to the database.
  ///   - recordsToDelete: The IDs of the records to delete permanently from the database.
  ///   - isAtomic: A Boolean value that indicates whether the entire operation fails when CloudKit can’t update one or
  ///     more records in a record zone.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A `Publisher` that emits progress of the saved `CKRecord`s, and the deleted `CKRecord.ID`s.
  ///   Progress is a `Double` where `0.0` indicates no progress, and `1.0` indicates completion.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public final func modify(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil,
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<((CKRecord, Double)?, CKRecord.ID?), Error> {
    let subject = PassthroughSubject<((CKRecord, Double)?, CKRecord.ID?), Error>()
    let operation = CKModifyRecordsOperation(
      recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete
    )
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.isAtomic = isAtomic
    operation.perRecordProgressBlock = { record, progress in
      if (progress < 1.0) {
        subject.send(((record, progress), nil))
      }
    }
    operation.perRecordCompletionBlock = { record, error in
      guard error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      subject.send(((record, 1.0), nil))
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

    return subject.propagateCancellationTo(operation)
  }

  /// Fetches the record with the specified ID.
  ///
  /// - Parameters:
  ///   - recordID: The record ID of the record to fetch.
  /// - Note: CombineCloudKit executes the fetch with a low priority. Use this method when you don’t require the record
  /// immediately.
  /// - Returns: A `Publisher` that emits the `CKRecord`, or an error if CombineCloudKit can't fetch it.
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449126-fetch)
  public final func fetchAtBackgroundPriority(
    withRecordID recordID: CKRecord.ID
  ) -> AnyPublisher<CKRecord, Error> {
    publisherFrom(fetch, with: recordID)
  }

  /// Fetches the record with the specified ID.
  ///
  /// - Parameters:
  ///   - recordID: The record ID of the record to fetch.
  ///   - desiredKeys: The fields of the record to fetch. Use this parameter to limit the amount of data that CloudKit
  ///     returns for the record. When CloudKit returns the record, it only includes fields with names that match one of
  ///     the keys in this parameter. The parameter's default value is `nil`, which instructs CloudKit to return all of
  ///     the record’s keys.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A `Publisher` that emits progress and the fetched `CKRecord` on completion, or an error if
  ///   CombineCloudKit can't fetch it. Progress is a `Double` where `0.0` indicates no progress, and `1.0` indicates completion.
  /// - SeeAlso: [CKFetchRecordsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation)
  public final func fetch(
    recordID: CKRecord.ID,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<(CKRecord?, Double?), Error> {
    fetch(recordIDs: [recordID], desiredKeys: desiredKeys, withConfiguration: configuration)
      .compactMap { (progress, record) in
      if let progress = progress, progress.1 < 1.0 {
        return (nil, progress.1)
      }
      
      if let record = record {
        return (record, 1.0)
      }
      
      return nil
      }.eraseToAnyPublisher()
  }

  /// Fetches multiple records.
  ///
  /// - Parameters:
  ///   - recordIDs: The record IDs of the records to fetch.
  ///   - desiredKeys: The fields of the records to fetch. Use this parameter to limit the amount of data that CloudKit
  ///     returns for each record. When CloudKit returns a record, it only includes fields with names that match one of
  ///     the keys in this parameter. The parameter's default value is `nil`, which instructs CloudKit to return all of
  ///     a record’s keys.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A `Publisher` that emits progress of the fetched `CKRecord.ID`s and the fetched `CKRecord`s, or an error if
  ///   CombineCloudKit can't fetch them. Progress is a `Double` where `0.0` indicates no progress, and `1.0` indicates completion.
  /// - SeeAlso: [CKFetchRecordsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation)
  public final func fetch(
    recordIDs: [CKRecord.ID],
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<((CKRecord.ID, Double)?, CKRecord?), Error> {
    let subject = PassthroughSubject<((CKRecord.ID, Double)?, CKRecord?), Error>()
    let operation = CKFetchRecordsOperation(recordIDs: recordIDs)
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.desiredKeys = desiredKeys
    operation.perRecordProgressBlock = { recordID, progress in
      subject.send(((recordID, progress), nil))
    }
    operation.perRecordCompletionBlock = { record, _, error in
      guard let record = record, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      subject.send((nil, record))
    }
    operation.fetchRecordsCompletionBlock = { _, error in
      guard error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
  }

  /// Fetches the current user record.
  ///
  /// - Parameters:
  ///   - desiredKeys: The fields of the record to fetch. Use this parameter to limit the amount of data that CloudKit
  ///     returns for the record. When CloudKit returns the record, it only includes fields with names that match one of
  ///     the keys in this parameter. The parameter's default value is `nil`, which instructs CloudKit to return all of
  ///     the record’s keys.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A `Publisher` that emits the `CKRecord`, or an error if CombineCloudKit can't fetch it.
  /// - SeeAlso: [fetchCurrentUserRecordOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation/1476070-fetchcurrentuserrecordoperation)
  public final func fetchCurrentUserRecord(
    desiredKeys _: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    let operation = CKFetchRecordsOperation.fetchCurrentUserRecordOperation()
    return publisherFrom(operation, configuration) { completion in
      operation.fetchRecordsCompletionBlock = completion
    }
  }

  /// Fetches records that match the specified query.
  ///
  /// - Parameters:
  ///   - recordType: The record type to search.
  ///   - predicate: The predicate to use for matching records.
  ///   - sortDescriptors: The sort descriptors for organizing the query’s results.
  ///   - zoneID: The ID of the record zone that contains the records to search. The value of this parameter limits the
  ///     scope of the search to only the records in the specified record zone. If you don’t specify a record zone, the
  ///     search includes all record zones.
  ///   - desiredKeys: The fields of the records to fetch. Use this parameter to limit the amount of data that CloudKit
  ///     returns for each record. When CloudKit returns a record, it only includes fields with names that match one of
  ///     the keys in this parameter. The parameter's default value is `nil`, which instructs CloudKit to return all of
  ///     a record’s keys.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A `Publisher` that emits any matching `CKRecord`s, or an error if CombineCloudKit can't perform the query.
  /// - SeeAlso: [CKQuery](https://developer.apple.com/documentation/cloudkit/ckquery)
  /// - SeeAlso: [CKQueryOperation](https://developer.apple.com/documentation/cloudkit/ckqueryoperation)
  /// - SeeAlso: [NSPredicate](https://developer.apple.com/documentation/foundation/nspredicate)
  /// - SeeAlso: [NSSortDescriptor](https://developer.apple.com/documentation/foundation/nssortdescriptor)
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
      query,
      inZoneWith: zoneID,
      desiredKeys: desiredKeys,
      withConfiguration: configuration
    )
  }

  /// Fetches records that match the specified query.
  ///
  /// - Parameters:
  ///   - query: The query for the search.
  ///   - zoneID: The ID of the record zone that contains the records to search. The value of this parameter limits the
  ///     scope of the search to only the records in the specified record zone. If you don’t specify a record zone, the
  ///     search includes all record zones.
  ///   - desiredKeys: The fields of the records to fetch. Use this parameter to limit the amount of data that CloudKit
  ///     returns for each record. When CloudKit returns a record, it only includes fields with names that match one of
  ///     the keys in this parameter. The parameter's default value is `nil`, which instructs CloudKit to return all of
  ///     a record’s keys.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A `Publisher` that emits any matching `CKRecord`s, or an error if CombineCloudKit can't perform the query.
  /// - SeeAlso: [CKQuery](https://developer.apple.com/documentation/cloudkit/ckquery)
  /// - SeeAlso: [CKQueryOperation](https://developer.apple.com/documentation/cloudkit/ckqueryoperation)
  /// - SeeAlso: [NSPredicate](https://developer.apple.com/documentation/foundation/nspredicate)
  /// - SeeAlso: [NSSortDescriptor](https://developer.apple.com/documentation/foundation/nssortdescriptor)
  public final func perform(
    _ query: CKQuery,
    inZoneWith zoneID: CKRecordZone.ID? = nil,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    QueryPublisher(database: self, query, zoneID, desiredKeys, configuration).eraseToAnyPublisher()
  }
}
