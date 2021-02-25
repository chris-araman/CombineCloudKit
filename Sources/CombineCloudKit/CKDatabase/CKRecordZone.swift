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
  public final func saveAtBackgroundPriority(
    recordZone: CKRecordZone
  ) -> AnyPublisher<CKRecordZone, Error> {
    publisherFrom(save, with: recordZone)
  }

  public final func save(
    recordZone: CKRecordZone,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    save(recordZones: [recordZone], withConfiguration: configuration)
  }

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

  public final func deleteAtBackgroundPriority(
    recordZoneID: CKRecordZone.ID
  ) -> AnyPublisher<CKRecordZone.ID, Error> {
    publisherFrom(delete, with: recordZoneID)
  }

  public final func delete(
    recordZoneID: CKRecordZone.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone.ID, Error> {
    delete(recordZoneIDs: [recordZoneID], withConfiguration: configuration)
  }

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

  public struct CCKModifyRecordZonePublishers {
    let saved: AnyPublisher<CKRecordZone, Error>
    let deleted: AnyPublisher<CKRecordZone.ID, Error>
  }

  public final func modify(
    recordZonesToSave: [CKRecordZone]? = nil,
    recordZoneIDsToDelete: [CKRecordZone.ID]? = nil,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> CCKModifyRecordZonePublishers {
    let operation = CKModifyRecordZonesOperation(
      recordZonesToSave: recordZonesToSave,
      recordZoneIDsToDelete: recordZoneIDsToDelete
    )
    return publisherFrom(
      operation,
      configuration,
      setCompletion: { completion in operation.modifyRecordZonesCompletionBlock = completion },
      initPublishers: CCKModifyRecordZonePublishers.init
    )
  }

  public final func fetchAtBackgroundPriority(
    withRecordZoneID recordZoneID: CKRecordZone.ID
  ) -> AnyPublisher<CKRecordZone, Error> {
    publisherFrom(fetch, with: recordZoneID)
  }

  public final func fetch(
    recordZoneID: CKRecordZone.ID,
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    fetch(recordZoneIDs: [recordZoneID], withConfiguration: configuration)
  }

  public final func fetch(
    recordZoneIDs: [CKRecordZone.ID],
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    let operation = CKFetchRecordZonesOperation(recordZoneIDs: recordZoneIDs)
    return publisherFrom(operation, configuration) { completion in
      operation.fetchRecordZonesCompletionBlock = completion
    }
  }

  public final func fetchAllRecordZonesAtBackgroundPriority()
    -> AnyPublisher<CKRecordZone, Error>
  {
    publisherFrom(fetchAllRecordZones)
  }

  public final func fetchAllRecordZones(
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    let operation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
    return publisherFrom(operation, configuration) { completion in
      operation.fetchRecordZonesCompletionBlock = completion
    }
  }
}
