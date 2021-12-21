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
  var space: DecisionSpace?

  init(_ database: MockDatabase, _ space: DecisionSpace? = nil) {
    self.database = database
    self.space = space
  }

  public func createFetchAllRecordZonesOperation() -> CCKFetchRecordZonesOperation {
    MockFetchRecordZonesOperation(database, space)
  }

  public func createFetchAllSubscriptionsOperation() -> CCKFetchSubscriptionsOperation {
    MockFetchSubscriptionsOperation(database, space)
  }

  public static let currentUserRecordID = CKRecord.ID(recordName: "CurrentUserRecord")

  public func createFetchCurrentUserRecordOperation() -> CCKFetchRecordsOperation {
    MockFetchRecordsOperation(database, space, [MockOperationFactory.currentUserRecordID])
  }

  public func createFetchRecordsOperation(recordIDs: [CKRecord.ID]) -> CCKFetchRecordsOperation {
    MockFetchRecordsOperation(database, space, recordIDs)
  }

  public func createFetchRecordZonesOperation(recordZoneIDs: [CKRecordZone.ID])
    -> CCKFetchRecordZonesOperation
  {
    MockFetchRecordZonesOperation(database, space, recordZoneIDs)
  }

  public func createFetchSubscriptionsOperation(
    subscriptionIDs: [CKSubscription.ID]
  ) -> CCKFetchSubscriptionsOperation {
    MockFetchSubscriptionsOperation(database, space, subscriptionIDs)
  }

  public func createModifyRecordsOperation(
    recordsToSave: [CKRecord]?, recordIDsToDelete: [CKRecord.ID]?
  ) -> CCKModifyRecordsOperation {
    MockModifyRecordsOperation(database, space, recordsToSave, recordIDsToDelete)
  }

  public func createModifyRecordZonesOperation(
    recordZonesToSave: [CKRecordZone]?, recordZoneIDsToDelete: [CKRecordZone.ID]?
  ) -> CCKModifyRecordZonesOperation {
    MockModifyRecordZonesOperation(database, space, recordZonesToSave, recordZoneIDsToDelete)
  }

  public func createModifySubscriptionsOperation(
    subscriptionsToSave: [CKSubscription]? = nil,
    subscriptionIDsToDelete: [CKSubscription.ID]? = nil
  ) -> CCKModifySubscriptionsOperation {
    MockModifySubscriptionsOperation(database, space, subscriptionsToSave, subscriptionIDsToDelete)
  }

  public func createQueryOperation() -> CCKQueryOperation {
    MockQueryOperation(database, space)
  }
}
