//
//  CCKDatabase+CKRecordZone.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/16/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension CCKDatabase {
  /// Saves a single record zone.
  ///
  /// - Parameters:
  ///   - recordZone: The record zone to save.
  /// - Note: CombineCloudKit executes the save with a low priority. Use this method when you don’t require the save to
  /// happen immediately.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the saved
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone), or an error if CombineCloudKit can't save it.
  /// The publisher ignores requests for cooperative cancellation.
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449108-save)
  public func saveAtBackgroundPriority(
    recordZone: CKRecordZone
  ) -> AnyPublisher<CKRecordZone, Error> {
    publisherAtBackgroundPriorityFrom(save, with: recordZone)
  }

  /// Saves a single record zone.
  ///
  /// - Parameters:
  ///   - recordZone: The record zone to save.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the saved
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone), or an error if CombineCloudKit can't save it.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public func save(
    recordZone: CKRecordZone,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    save(recordZones: [recordZone], withConfiguration: configuration)
  }

  /// Saves multiple record zones.
  ///
  /// - Parameters:
  ///   - recordZones: The record zones to save.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the saved
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone)s, or an error if CombineCloudKit can't save them.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public func save(
    recordZones: [CKRecordZone],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    modify(recordZonesToSave: recordZones, withConfiguration: configuration).compactMap {
      saved, _ in
      saved
    }.eraseToAnyPublisher()
  }

  /// Deletes a single record zone.
  ///
  /// - Parameters:
  ///   - recordZoneID: The ID of the record zone to delete.
  /// - Note: CombineCloudKit executes the delete with a low priority. Use this method when you don’t require the delete
  /// to happen immediately.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the deleted
  /// [`CKRecordZone.ID`](https://developer.apple.com/documentation/cloudkit/ckrecordzone/id), or an error if CombineCloudKit can't delete it.
  /// The publisher ignores requests for cooperative cancellation.
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449118-delete)
  public func deleteAtBackgroundPriority(
    recordZoneID: CKRecordZone.ID
  ) -> AnyPublisher<CKRecordZone.ID, Error> {
    publisherAtBackgroundPriorityFrom(delete, with: recordZoneID)
  }

  /// Deletes a single record zone.
  ///
  /// - Parameters:
  ///   - recordZoneID: The ID of the record zone to delete.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the deleted
  /// [`CKRecordZone.ID`](https://developer.apple.com/documentation/cloudkit/ckrecordzone/id), or an error if CombineCloudKit can't delete
  /// it.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public func delete(
    recordZoneID: CKRecordZone.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone.ID, Error> {
    delete(recordZoneIDs: [recordZoneID], withConfiguration: configuration)
  }

  /// Deletes multiple record zones.
  ///
  /// - Parameters:
  ///   - recordZoneIDs: The IDs of the record zones to delete.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the deleted
  /// [`CKRecordZone.ID`](https://developer.apple.com/documentation/cloudkit/ckrecordzone/id)s, or an error if CombineCloudKit can't delete
  /// them.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public func delete(
    recordZoneIDs: [CKRecordZone.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone.ID, Error> {
    modify(recordZoneIDsToDelete: recordZoneIDs, withConfiguration: configuration).compactMap {
      _, deleted in
      deleted
    }.eraseToAnyPublisher()
  }

  /// Modifies one or more record zones.
  ///
  /// - Parameters:
  ///   - recordZonesToSave: The record zones to save.
  ///   - recordZonesToDelete: The IDs of the record zones to delete.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the saved
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone)s and the deleted
  /// [`CKRecordZone.ID`](https://developer.apple.com/documentation/cloudkit/ckrecordzone/id)s, or an
  ///   error if CombineCloudKit can't modify them.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public func modify(
    recordZonesToSave: [CKRecordZone]? = nil,
    recordZoneIDsToDelete: [CKRecordZone.ID]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<(CKRecordZone?, CKRecordZone.ID?), Error> {
    let operation = operationFactory.createModifyRecordZonesOperation(
      recordZonesToSave: recordZonesToSave,
      recordZoneIDsToDelete: recordZoneIDsToDelete
    )
    return publisherFromModify(operation, configuration) { completion in
      operation.modifyRecordZonesCompletionBlock = completion
    }
  }

  /// Fetches the record zone with the specified ID.
  ///
  /// - Parameters:
  ///   - recordZoneID: The ID of the record zone to fetch.
  /// - Note: CombineCloudKit executes the fetch with a low priority. Use this method when you don’t require the record
  /// zone immediately.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone), or an error if CombineCloudKit can't fetch it.
  /// The publisher ignores requests for cooperative cancellation.
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449104-fetch)
  public func fetchAtBackgroundPriority(
    withRecordZoneID recordZoneID: CKRecordZone.ID
  ) -> AnyPublisher<CKRecordZone, Error> {
    publisherAtBackgroundPriorityFrom(fetch, with: recordZoneID)
  }

  /// Fetches the record zone with the specified ID.
  ///
  /// - Parameters:
  ///   - recordZoneID: The ID of the record zone to fetch.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone), or an error if CombineCloudKit can't fetch it.
  /// - SeeAlso: [CKFetchRecordZonesOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordzonesoperation)
  public func fetch(
    recordZoneID: CKRecordZone.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    fetch(recordZoneIDs: [recordZoneID], withConfiguration: configuration)
  }

  /// Fetches multiple record zones.
  ///
  /// - Parameters:
  ///   - recordZoneIDs: The IDs of the record zones to fetch.
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone)s, or an error if CombineCloudKit can't fetch them.
  /// - SeeAlso: [CKFetchRecordZonesOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordzonesoperation)
  public func fetch(
    recordZoneIDs: [CKRecordZone.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    let operation = operationFactory.createFetchRecordZonesOperation(recordZoneIDs: recordZoneIDs)
    return publisherFromFetch(operation, configuration) { completion in
      operation.fetchRecordZonesCompletionBlock = completion
    }
  }

  /// Fetches the database's record zones.
  ///
  /// - Note: CombineCloudKit executes the fetch with a low priority. Use this method when you don’t require the record
  /// zones immediately.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone)s, or an error if CombineCloudKit can't fetch them.
  /// - SeeAlso: [fetchAllRecordZones](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449112-fetchallrecordzones)
  public func fetchAllRecordZonesAtBackgroundPriority()
    -> AnyPublisher<CKRecordZone, Error>
  {
    publisherFromFetchAll(fetchAllRecordZones)
  }

  /// Fetches the database's record zones.
  ///
  /// - Parameters:
  ///   - configuration: The configuration to use for the underlying operation. If you don't specify a configuration,
  ///     the operation will use a default configuration.
  /// - Returns: A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) that emits the
  /// [`CKRecordZone`](https://developer.apple.com/documentation/cloudkit/ckrecordzone)s, or an error if CombineCloudKit can't fetch them.
  /// - SeeAlso:
  /// [fetchAllRecordZonesOperation]
  /// (https://developer.apple.com/documentation/cloudkit/ckfetchrecordzonesoperation/1514890-fetchallrecordzonesoperation)
  public func fetchAllRecordZones(
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    let operation = operationFactory.createFetchAllRecordZonesOperation()
    return publisherFromFetch(operation, configuration) { completion in
      operation.fetchRecordZonesCompletionBlock = completion
    }
  }
}
