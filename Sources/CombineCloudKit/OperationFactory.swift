//
//  OperationFactory.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

/// Allows dependency injection for testing.
var operationFactory: OperationFactory = CKOperationFactory()

protocol OperationFactory {
  func createFetchAllRecordZonesOperation() -> CCKFetchRecordZonesOperation

  func createFetchAllSubscriptionsOperation() -> CCKFetchSubscriptionsOperation

  func createFetchCurrentUserRecordOperation() -> CCKFetchRecordsOperation

  func createFetchRecordsOperation(
    recordIDs: [CKRecord.ID]
  ) -> CCKFetchRecordsOperation

  func createFetchRecordZonesOperation(
    recordZoneIDs: [CKRecordZone.ID]
  ) -> CCKFetchRecordZonesOperation

  func createFetchSubscriptionsOperation(
    subscriptionIDs: [CKSubscription.ID]
  ) -> CCKFetchSubscriptionsOperation

  func createModifyRecordsOperation(
    recordsToSave: [CKRecord]?,
    recordIDsToDelete: [CKRecord.ID]?
  ) -> CCKModifyRecordsOperation

  func createModifyRecordZonesOperation(
    recordZonesToSave: [CKRecordZone]?,
    recordZoneIDsToDelete: [CKRecordZone.ID]?
  ) -> CCKModifyRecordZonesOperation

  func createModifySubscriptionsOperation(
    subscriptionsToSave: [CKSubscription]?,
    subscriptionIDsToDelete: [CKSubscription.ID]?
  ) -> CCKModifySubscriptionsOperation

  func createQueryOperation() -> CCKQueryOperation
}

class CKOperationFactory: OperationFactory {
  func createFetchAllRecordZonesOperation() -> CCKFetchRecordZonesOperation {
    CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
  }

  func createFetchAllSubscriptionsOperation() -> CCKFetchSubscriptionsOperation {
    CKFetchSubscriptionsOperation.fetchAllSubscriptionsOperation()
  }

  func createFetchCurrentUserRecordOperation() -> CCKFetchRecordsOperation {
    CKFetchRecordsOperation.fetchCurrentUserRecordOperation()
  }

  func createFetchRecordsOperation(
    recordIDs: [CKRecord.ID]
  ) -> CCKFetchRecordsOperation {
    CKFetchRecordsOperation(recordIDs: recordIDs)
  }

  func createFetchRecordZonesOperation(
    recordZoneIDs: [CKRecordZone.ID]
  ) -> CCKFetchRecordZonesOperation {
    CKFetchRecordZonesOperation(recordZoneIDs: recordZoneIDs)
  }

  func createFetchSubscriptionsOperation(
    subscriptionIDs: [CKSubscription.ID]
  ) -> CCKFetchSubscriptionsOperation {
    CKFetchSubscriptionsOperation(subscriptionIDs: subscriptionIDs)
  }

  func createModifyRecordsOperation(
    recordsToSave: [CKRecord]? = nil,
    recordIDsToDelete: [CKRecord.ID]? = nil
  ) -> CCKModifyRecordsOperation {
    CKModifyRecordsOperation(
      recordsToSave: recordsToSave,
      recordIDsToDelete: recordIDsToDelete
    )
  }

  func createModifyRecordZonesOperation(
    recordZonesToSave: [CKRecordZone]? = nil,
    recordZoneIDsToDelete: [CKRecordZone.ID]? = nil
  ) -> CCKModifyRecordZonesOperation {
    CKModifyRecordZonesOperation(
      recordZonesToSave: recordZonesToSave,
      recordZoneIDsToDelete: recordZoneIDsToDelete
    )
  }

  func createModifySubscriptionsOperation(
    subscriptionsToSave: [CKSubscription]? = nil,
    subscriptionIDsToDelete: [CKSubscription.ID]? = nil
  ) -> CCKModifySubscriptionsOperation {
    CKModifySubscriptionsOperation(
      subscriptionsToSave: subscriptionsToSave,
      subscriptionIDsToDelete: subscriptionIDsToDelete
    )
  }

  func createQueryOperation() -> CCKQueryOperation {
    CKQueryOperation()
  }
}
