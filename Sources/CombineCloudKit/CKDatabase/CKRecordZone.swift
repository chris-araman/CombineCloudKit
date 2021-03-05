//
//  CKRecordZone.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/16/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension CKDatabase {
  /// Saves a single record zone.
  ///
  /// CombineCloudKit executes the save with a low priority. Use this method when you don’t require the save to happen
  /// immediately.
  /// - Returns: A `Publisher` that emits the saved `CKRecordZone`, or an error if CombineCloudKit can't save it.
  /// - SeeAlso: [`save`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449108-save)
  public final func saveAtBackgroundPriority(
    recordZone: CKRecordZone
  ) -> AnyPublisher<CKRecordZone, Error> {
    publisherFrom(save, with: recordZone)
  }

  /// Saves a single record zone.
  ///
  /// - Returns: A `Publisher` that emits the saved `CKRecordZone`, or an error if CombineCloudKit can't save it.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public final func save(
    recordZone: CKRecordZone,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    save(recordZones: [recordZone], withConfiguration: configuration)
  }

  /// Saves multiple record zones.
  ///
  /// - Returns: A `Publisher` that emits the saved `CKRecordZone`s, or an error if CombineCloudKit can't save them.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public final func save(
    recordZones: [CKRecordZone],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    let operation = CKModifyRecordZonesOperation(
      recordZonesToSave: recordZones, recordZoneIDsToDelete: nil
    )
    return publisherFrom(operation, configuration) { completion in
      operation.modifyRecordZonesCompletionBlock = completion
    }
  }

  /// Deletes a single record zone.
  ///
  /// CombineCloudKit executes the delete with a low priority. Use this method when you don’t require the delete to
  /// happen immediately.
  /// - Returns: A `Publisher` that emits the saved `CKRecordZone.ID`, or an error if CombineCloudKit can't save it.
  /// - SeeAlso: [`delete`](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449118-delete)
  public final func deleteAtBackgroundPriority(
    recordZoneID: CKRecordZone.ID
  ) -> AnyPublisher<CKRecordZone.ID, Error> {
    publisherFrom(delete, with: recordZoneID)
  }

  /// Deletes a single record zone.
  ///
  /// - Returns: A `Publisher` that emits the deleted `CKRecordZone.ID`, or an error if CombineCloudKit can't delete
  /// it.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public final func delete(
    recordZoneID: CKRecordZone.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone.ID, Error> {
    delete(recordZoneIDs: [recordZoneID], withConfiguration: configuration)
  }

  /// Deletes multiple record zones.
  ///
  /// - Returns: A `Publisher` that emits the deleted `CKRecordZone.ID`s, or an error if CombineCloudKit can't delete
  /// them.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public final func delete(
    recordZoneIDs: [CKRecordZone.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone.ID, Error> {
    let operation = CKModifyRecordZonesOperation(
      recordZonesToSave: nil, recordZoneIDsToDelete: recordZoneIDs
    )
    return publisherFrom(operation, configuration) { completion in
      operation.modifyRecordZonesCompletionBlock = completion
    }
  }

  /// `Publisher`s returned by `modify`.
  ///
  /// Canceling either `Publisher` cancels the underlying `CKModifyRecordZonesOperation`.
  public struct CCKModifyRecordZonesPublishers {
    let saved: AnyPublisher<CKRecordZone, Error>
    let deleted: AnyPublisher<CKRecordZone.ID, Error>
  }

  /// Modifies one or more record zones.
  ///
  /// - Returns: A `CCKModifyRecordZonesPublishers`.
  /// - SeeAlso: [`CKModifyRecordZonesOperation`](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordzonesoperation)
  public final func modify(
    recordZonesToSave: [CKRecordZone]? = nil,
    recordZoneIDsToDelete: [CKRecordZone.ID]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> CCKModifyRecordZonesPublishers {
    let operation = CKModifyRecordZonesOperation(
      recordZonesToSave: recordZonesToSave,
      recordZoneIDsToDelete: recordZoneIDsToDelete
    )
    return publisherFrom(
      operation,
      configuration,
      setCompletion: { completion in operation.modifyRecordZonesCompletionBlock = completion },
      initPublishers: CCKModifyRecordZonesPublishers.init
    )
  }

  /// Fetches the record zone with the specified ID.
  ///
  /// CombineCloudKit executes the fetch with a low priority. Use this method when you don’t require the record zone
  /// immediately.
  /// - Returns: A `Publisher` that emits the `CKRecordZone`, or an error if CombineCloudKit can't fetch it.
  /// - SeeAlso: [fetch](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449104-fetch)
  public final func fetchAtBackgroundPriority(
    withRecordZoneID recordZoneID: CKRecordZone.ID
  ) -> AnyPublisher<CKRecordZone, Error> {
    publisherFrom(fetch, with: recordZoneID)
  }

  /// Fetches the record zone with the specified ID.
  ///
  /// - Returns: A `Publisher` that emits the `CKRecordZone`, or an error if CombineCloudKit can't fetch it.
  /// - SeeAlso: [CKFetchRecordZonesOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordzonesoperation)
  public final func fetch(
    recordZoneID: CKRecordZone.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    fetch(recordZoneIDs: [recordZoneID], withConfiguration: configuration)
  }

  /// Fetches multiple record zones.
  ///
  /// - Returns: A `Publisher` that emits the `CKRecordZone`s, or an error if CombineCloudKit can't fetch them.
  /// - SeeAlso: [CKFetchRecordZonesOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordzonesoperation)
  public final func fetch(
    recordZoneIDs: [CKRecordZone.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    let operation = CKFetchRecordZonesOperation(recordZoneIDs: recordZoneIDs)
    return publisherFrom(operation, configuration) { completion in
      operation.fetchRecordZonesCompletionBlock = completion
    }
  }

  /// Fetches the database's record zones.
  ///
  /// CombineCloudKit executes the fetch with a low priority. Use this method when you don’t require the record zones
  /// immediately.
  /// - Returns: A `Publisher` that emits the `CKRecordZone`s, or an error if CombineCloudKit can't fetch them.
  /// - SeeAlso: [fetchAllRecordZones](https://developer.apple.com/documentation/cloudkit/ckdatabase/1449112-fetchallrecordzones)
  public final func fetchAllRecordZonesAtBackgroundPriority()
    -> AnyPublisher<CKRecordZone, Error>
  {
    publisherFrom(fetchAllRecordZones)
  }

  /// Fetches the database's record zones.
  ///
  /// - Returns: A `Publisher` that emits the `CKRecordZone`s, or an error if CombineCloudKit can't fetch them.
  /// - SeeAlso: [fetchAllRecordZonesOperation](https://developer.apple.com/documentation/cloudkit/ckfetchrecordzonesoperation/1514890-fetchallrecordzonesoperation)
  public final func fetchAllRecordZones(
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    let operation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
    return publisherFrom(operation, configuration) { completion in
      operation.fetchRecordZonesCompletionBlock = completion
    }
  }
}
