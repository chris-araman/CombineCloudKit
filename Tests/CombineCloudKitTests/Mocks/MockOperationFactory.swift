//
//  MockOperationFactory.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import CombineCloudKit

public class MockOperationFactory: OperationFactory {
  let database: MockDatabase

  public init(_ database: MockDatabase) {
    self.database = database
  }

  public func createFetchAllRecordZonesOperation() -> CCKFetchRecordZonesOperation {
    MockFetchRecordZonesOperation(database)
  }

  public func createFetchAllSubscriptionsOperation() -> CCKFetchSubscriptionsOperation {
    MockFetchSubscriptionsOperation(database)
  }

  public static let currentUserRecordID = CKRecord.ID(recordName: "CurrentUserRecord")

  public func createFetchCurrentUserRecordOperation() -> CCKFetchRecordsOperation {
    MockFetchRecordsOperation(database, [MockOperationFactory.currentUserRecordID])
  }

  public func createFetchRecordsOperation(recordIDs: [CKRecord.ID]) -> CCKFetchRecordsOperation {
    MockFetchRecordsOperation(database, recordIDs)
  }

  public func createFetchRecordZonesOperation(recordZoneIDs: [CKRecordZone.ID])
    -> CCKFetchRecordZonesOperation
  {
    MockFetchRecordZonesOperation(database, recordZoneIDs)
  }

  public func createFetchSubscriptionsOperation(
    subscriptionIDs: [CKSubscription.ID]
  ) -> CCKFetchSubscriptionsOperation {
    MockFetchSubscriptionsOperation(database, subscriptionIDs)
  }

  public func createModifyRecordsOperation(
    recordsToSave: [CKRecord]?, recordIDsToDelete: [CKRecord.ID]?
  )
    -> CCKModifyRecordsOperation
  {
    MockModifyRecordsOperation(database, recordsToSave, recordIDsToDelete)
  }

  public func createModifyRecordZonesOperation(
    recordZonesToSave: [CKRecordZone]?, recordZoneIDsToDelete: [CKRecordZone.ID]?
  ) -> CCKModifyRecordZonesOperation {
    MockModifyRecordZonesOperation(database, recordZonesToSave, recordZoneIDsToDelete)
  }

  public func createModifySubscriptionsOperation(
    subscriptionsToSave: [CKSubscription]? = nil,
    subscriptionIDsToDelete: [CKSubscription.ID]? = nil
  ) -> CCKModifySubscriptionsOperation {
    MockModifySubscriptionsOperation(database, subscriptionsToSave, subscriptionIDsToDelete)
  }
}
