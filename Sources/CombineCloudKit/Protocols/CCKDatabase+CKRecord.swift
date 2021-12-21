//
//  CCKDatabase+CKRecord.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/16/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension CCKDatabase {
  /// Saves a single record.
  ///
  /// - Parameters:
  ///   - record: The record to save to the database.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
  ///   - clientChangeTokenData: A token that tracks local changes to records.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the saved
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord), or an error if CombineCloudKit can't save it.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func save(
    record: CKRecord,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
    clientChangeTokenData: Data? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    save(
      records: [record],
      withConfiguration: configuration,
      savePolicy: savePolicy,
      clientChangeTokenData: clientChangeTokenData)
  }

  /// Saves multiple records.
  ///
  /// - Parameters:
  ///   - records: The records to save to the database.
  ///   - isAtomic: A Boolean value that indicates whether the entire operation fails when CloudKit can’t save one or
  ///     more records in a record zone.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
  ///   - clientChangeTokenData: A token that tracks local changes to records.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the saved
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s, or an error if CombineCloudKit can't save them.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func save(
    records: [CKRecord],
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
    clientChangeTokenData: Data? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    modify(
      recordsToSave: records,
      recordIDsToDelete: nil,
      atomically: isAtomic,
      withConfiguration: configuration,
      savePolicy: savePolicy,
      clientChangeTokenData: clientChangeTokenData
    ).compactMap { saved, _ in
      saved
    }.eraseToAnyPublisher()
  }

  /// Saves a single record.
  ///
  /// - Parameters:
  ///   - record: The record to save to the database.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Note: CombineCloudKit executes the save with a low priority. Use this method when you don’t require the save to
  /// happen immediately.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the saved
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord), or an error if CombineCloudKit can't save it.
  /// The publisher ignores requests for cooperative cancellation.
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449114-save)
  public func saveAtBackgroundPriority(record: CKRecord) -> AnyPublisher<CKRecord, Error> {
    publisherAtBackgroundPriorityFrom(save, with: record)
  }

  /// Saves a single record.
  ///
  /// - Parameters:
  ///   - record: The record to save to the database.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
  ///   - clientChangeTokenData: A token that tracks local changes to records.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the ``Progress`` of the saved
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord), or an error if CombineCloudKit can't save it.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func saveWithProgress(
    record: CKRecord,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
    clientChangeTokenData: Data? = nil
  ) -> AnyPublisher<(CKRecord, Progress), Error> {
    saveWithProgress(
      records: [record],
      withConfiguration: configuration,
      savePolicy: savePolicy,
      clientChangeTokenData: clientChangeTokenData)
  }

  /// Saves multiple records.
  ///
  /// - Parameters:
  ///   - records: The records to save to the database.
  ///   - isAtomic: A Boolean value that indicates whether the entire operation fails when CloudKit can’t save one or
  ///     more records in a record zone.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
  ///   - clientChangeTokenData: A token that tracks local changes to records.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the ``Progress`` of the saved
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s, or an error if CombineCloudKit can't save them.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func saveWithProgress(
    records: [CKRecord],
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
    clientChangeTokenData: Data? = nil
  ) -> AnyPublisher<(CKRecord, Progress), Error> {
    modifyWithProgress(
      recordsToSave: records,
      recordIDsToDelete: nil,
      atomically: isAtomic,
      withConfiguration: configuration,
      savePolicy: savePolicy,
      clientChangeTokenData: clientChangeTokenData
    ).compactMap { progress, _ in
      progress
    }.eraseToAnyPublisher()
  }

  /// Deletes a single record.
  ///
  /// - Parameters:
  ///   - recordID: The ID of the record to delete permanently from the database.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the deleted
  /// [`CKRecord.ID`](https://developer.apple.com/documentation/cloudkit/ckrecord/id), or an error if CombineCloudKit can't delete
  /// it.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func delete(
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
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the deleted
  /// [`CKRecord.ID`](https://developer.apple.com/documentation/cloudkit/ckrecord/id)s, or an error if CombineCloudKit can't delete
  /// them.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
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
    ).compactMap { _, deleted in
      deleted
    }.eraseToAnyPublisher()
  }

  /// Deletes a single record.
  ///
  /// - Parameters:
  ///   - recordID: The ID of the record to delete permanently from the database.
  /// - Note: CombineCloudKit executes the delete with a low priority. Use this method when you don’t require the delete
  /// to happen immediately.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the deleted
  /// [`CKRecord.ID`](https://developer.apple.com/documentation/cloudkit/ckrecord/id), or an error if CombineCloudKit can't delete it.
  /// The publisher ignores requests for cooperative cancellation.
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449122-delete)
  public func deleteAtBackgroundPriority(recordID: CKRecord.ID)
    -> AnyPublisher<CKRecord.ID, Error>
  {
    publisherAtBackgroundPriorityFrom(delete, with: recordID)
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
  ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
  ///   - clientChangeTokenData: A token that tracks local changes to records.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the saved
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s and the deleted
  /// [`CKRecord.ID`](https://developer.apple.com/documentation/cloudkit/ckrecord/id)s.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func modify(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil,
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
    clientChangeTokenData: Data? = nil
  ) -> AnyPublisher<(CKRecord?, CKRecord.ID?), Error> {
    modifyWithProgress(
      recordsToSave: recordsToSave,
      recordIDsToDelete: recordIDsToDelete,
      atomically: isAtomic,
      withConfiguration: configuration,
      savePolicy: savePolicy,
      clientChangeTokenData: clientChangeTokenData
    ).compactMap { saved, deleted in
      if let deleted = deleted {
        return (nil, deleted)
      }

      if let saved = saved,
        case (let record, let progress) = saved,
        case .complete = progress
      {
        return (record, nil)
      }

      return nil
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
  ///   - savePolicy: The policy to apply when the server contains a newer version of a specific record.
  ///   - clientChangeTokenData: A token that tracks local changes to records.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the ``Progress`` of the saved
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s, and the deleted
  /// [`CKRecord.ID`](https://developer.apple.com/documentation/cloudkit/ckrecord/id)s.
  /// - SeeAlso: [`CKModifyRecordsOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
  public func modifyWithProgress(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil,
    atomically isAtomic: Bool = true,
    withConfiguration configuration: CKOperation.Configuration? = nil,
    savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged,
    clientChangeTokenData: Data? = nil
  ) -> AnyPublisher<((CKRecord, Progress)?, CKRecord.ID?), Error> {
    let subject = PassthroughSubject<((CKRecord, Progress)?, CKRecord.ID?), Error>()
    let operation = operationFactory.createModifyRecordsOperation(
      recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete
    )
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.savePolicy = savePolicy
    operation.clientChangeTokenData = clientChangeTokenData
    operation.isAtomic = isAtomic
    operation.perRecordProgressBlock = { record, rawProgress in
      let progress = Progress(rawValue: rawProgress)
      if progress != .complete {
        subject.send(((record, progress), nil))
      }
    }
    operation.perRecordCompletionBlock = { record, error in
      guard error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      subject.send(((record, .complete), nil))
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

    return Deferred { () -> PassthroughSubject<((CKRecord, Progress)?, CKRecord.ID?), Error> in
      DispatchQueue.main.async {
        self.add(operation)
      }

      return subject
    }.propagateCancellationTo(operation)
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
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the fetched
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord), or an error if CombineCloudKit can't fetch it.
  /// - SeeAlso: [CKFetchRecordsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation)
  public func fetch(
    recordID: CKRecord.ID,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    fetch(recordIDs: [recordID], desiredKeys: desiredKeys, withConfiguration: configuration)
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
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the fetched
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s, or an error if CombineCloudKit can't fetch them.
  /// - SeeAlso: [CKFetchRecordsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation)
  public func fetch(
    recordIDs: [CKRecord.ID],
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    fetchWithProgress(
      recordIDs: recordIDs,
      desiredKeys: desiredKeys,
      withConfiguration: configuration
    ).compactMap { _, record in
      record
    }.eraseToAnyPublisher()
  }

  /// Fetches the record with the specified ID.
  ///
  /// - Parameters:
  ///   - recordID: The record ID of the record to fetch.
  /// - Note: CombineCloudKit executes the fetch with a low priority. Use this method when you don’t require the record
  /// immediately.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord), or an error if CombineCloudKit can't fetch it.
  /// The publisher ignores requests for cooperative cancellation.
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449126-fetch)
  public func fetchAtBackgroundPriority(
    withRecordID recordID: CKRecord.ID
  ) -> AnyPublisher<CKRecord, Error> {
    publisherAtBackgroundPriorityFrom(fetch, with: recordID)
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
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits ``Progress`` and the fetched
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord) on completion, or an error if
  ///   CombineCloudKit can't fetch it.
  /// - SeeAlso: [CKFetchRecordsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation)
  public func fetchWithProgress(
    recordID: CKRecord.ID,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<((CKRecord.ID, Progress)?, CKRecord?), Error> {
    fetchWithProgress(
      recordIDs: [recordID],
      desiredKeys: desiredKeys,
      withConfiguration: configuration
    )
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
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the ``Progress`` of the fetched
  /// [`CKRecord.ID`](https://developer.apple.com/documentation/cloudkit/ckrecord/id)s and the fetched
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s, or an error if
  ///   CombineCloudKit can't fetch them.
  /// - SeeAlso: [CKFetchRecordsOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation)
  public func fetchWithProgress(
    recordIDs: [CKRecord.ID],
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<((CKRecord.ID, Progress)?, CKRecord?), Error> {
    let subject = PassthroughSubject<((CKRecord.ID, Progress)?, CKRecord?), Error>()
    let operation = operationFactory.createFetchRecordsOperation(recordIDs: recordIDs)
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.desiredKeys = desiredKeys
    operation.perRecordProgressBlock = { recordID, rawProgress in
      let progress = Progress(rawValue: rawProgress)
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

    // TODO: Ensure we only add the operation once, for every place we do a deferred add.
    return Deferred { () -> PassthroughSubject<((CKRecord.ID, Progress)?, CKRecord?), Error> in
      DispatchQueue.main.async {
        self.add(operation)
      }

      return subject
    }.propagateCancellationTo(operation)
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
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord), or an error if CombineCloudKit can't fetch it.
  /// - SeeAlso:
  /// [fetchCurrentUserRecordOperation]
  /// (https://developer.apple.com/documentation/cloudkit/ckfetchrecordsoperation/1476070-fetchcurrentuserrecordoperation)
  public func fetchCurrentUserRecord(
    desiredKeys _: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    let operation = operationFactory.createFetchCurrentUserRecordOperation()
    return publisherFromFetch(operation, configuration) { completion in
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
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits any matching
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s, or an error if CombineCloudKit can't perform the query.
  /// - SeeAlso: [CKQuery](https://developer.apple.com/documentation/cloudkit/ckquery)
  /// - SeeAlso: [CKQueryOperation](https://developer.apple.com/documentation/cloudkit/ckqueryoperation)
  /// - SeeAlso: [NSPredicate](https://developer.apple.com/documentation/foundation/nspredicate)
  /// - SeeAlso: [NSSortDescriptor](https://developer.apple.com/documentation/foundation/nssortdescriptor)
  public func performQuery(
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
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits any matching
  /// [`CKRecord`](https://developer.apple.com/documentation/cloudkit/ckrecord)s, or an error if CombineCloudKit can't perform the query.
  /// - SeeAlso: [CKQuery](https://developer.apple.com/documentation/cloudkit/ckquery)
  /// - SeeAlso: [CKQueryOperation](https://developer.apple.com/documentation/cloudkit/ckqueryoperation)
  /// - SeeAlso: [NSPredicate](https://developer.apple.com/documentation/foundation/nspredicate)
  /// - SeeAlso: [NSSortDescriptor](https://developer.apple.com/documentation/foundation/nssortdescriptor)
  public func perform(
    _ query: CKQuery,
    inZoneWith zoneID: CKRecordZone.ID? = nil,
    desiredKeys: [CKRecord.FieldKey]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecord, Error> {
    QueryPublisher(database: self, query, zoneID, desiredKeys, configuration).eraseToAnyPublisher()
  }
}
