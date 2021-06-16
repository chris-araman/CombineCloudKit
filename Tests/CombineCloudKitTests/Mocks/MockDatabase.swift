//
//  MockDatabase.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Foundation

@testable import CombineCloudKit

public class MockDatabase: CCKDatabase {
  let space: DecisionSpace?
  let queue: DispatchQueue

  init(_ space: DecisionSpace? = nil) {
    self.space = space
    self.queue = DispatchQueue(label: String(describing: type(of: self)), attributes: [.concurrent])
  }

  var records = [CKRecord.ID: CKRecord]()
  var recordZones = [CKRecordZone.ID: CKRecordZone]()
  var subscriptions = [CKSubscription.ID: CKSubscription]()

  public func delete(
    withRecordID recordID: CKRecord.ID, completionHandler: @escaping (CKRecord.ID?, Error?) -> Void
  ) {
    queue.async(flags: .barrier) {
      if let space = self.space, space.decide() {
        completionHandler(nil, MockError.simulated)
        return
      }

      let removed = self.records.removeValue(forKey: recordID)
      guard let removedID = removed?.recordID else {
        completionHandler(nil, MockError.doesNotExist)
        return
      }

      completionHandler(removedID, nil)
    }
  }

  public func delete(
    withRecordZoneID zoneID: CKRecordZone.ID,
    completionHandler: @escaping (CKRecordZone.ID?, Error?) -> Void
  ) {
    queue.async(flags: .barrier) {
      if let space = self.space, space.decide() {
        completionHandler(nil, MockError.simulated)
        return
      }

      let removed = self.recordZones.removeValue(forKey: zoneID)
      guard let removedID = removed?.zoneID else {
        completionHandler(nil, MockError.doesNotExist)
        return
      }

      completionHandler(removedID, nil)
    }
  }

  public func delete(
    withSubscriptionID subscriptionID: CKSubscription.ID,
    completionHandler: @escaping (String?, Error?) -> Void
  ) {
    queue.async(flags: .barrier) {
      if let space = self.space, space.decide() {
        completionHandler(nil, MockError.simulated)
        return
      }

      let removed = self.subscriptions.removeValue(forKey: subscriptionID)
      guard let removedID = removed?.subscriptionID else {
        completionHandler(nil, MockError.doesNotExist)
        return
      }

      completionHandler(removedID, nil)
    }
  }

  public func fetch(
    withRecordID recordID: CKRecord.ID,
    completionHandler: @escaping (CKRecord?, Error?) -> Void
  ) {
    queue.async {
      if let space = self.space, space.decide() {
        completionHandler(nil, MockError.simulated)
        return
      }

      guard let record = self.records[recordID] else {
        completionHandler(nil, MockError.doesNotExist)
        return
      }

      completionHandler(record, nil)
    }
  }

  public func fetch(
    withRecordZoneID zoneID: CKRecordZone.ID,
    completionHandler: @escaping (CKRecordZone?, Error?) -> Void
  ) {
    queue.async {
      if let space = self.space, space.decide() {
        completionHandler(nil, MockError.simulated)
        return
      }

      guard let recordZone = self.recordZones[zoneID] else {
        completionHandler(nil, MockError.doesNotExist)
        return
      }

      completionHandler(recordZone, nil)
    }
  }

  public func fetch(
    withSubscriptionID subscriptionID: CKSubscription.ID,
    completionHandler: @escaping (CKSubscription?, Error?) -> Void
  ) {
    queue.async {
      if let space = self.space, space.decide() {
        completionHandler(nil, MockError.simulated)
        return
      }

      guard let subscription = self.subscriptions[subscriptionID] else {
        completionHandler(nil, MockError.doesNotExist)
        return
      }

      completionHandler(subscription, nil)
    }
  }

  public func fetchAllRecordZones(completionHandler: @escaping ([CKRecordZone]?, Error?) -> Void) {
    queue.async {
      if let space = self.space, space.decide() {
        completionHandler(nil, MockError.simulated)
        return
      }

      completionHandler(Array(self.recordZones.values), nil)
    }
  }

  public func fetchAllSubscriptions(
    completionHandler: @escaping ([CKSubscription]?, Error?) -> Void
  ) {
    queue.async {
      if let space = self.space, space.decide() {
        completionHandler(nil, MockError.simulated)
        return
      }

      completionHandler(Array(self.subscriptions.values), nil)
    }
  }

  public func perform(
    _ query: CKQuery,
    inZoneWith _: CKRecordZone.ID?,
    completionHandler: @escaping ([CKRecord]?, Error?) -> Void
  ) {
    queue.async {
      if let space = self.space, space.decide() {
        completionHandler(nil, MockError.simulated)
        return
      }

      // Our simulated queries will return only records of matching type.
      // We will ignore the predicate and other CKQuery fields.
      let results = self.records.compactMap { key, value in
        value.recordType == query.recordType ? value : nil
      }

      completionHandler(results, nil)
    }
  }

  public func save(
    _ record: CKRecord, completionHandler: @escaping (CKRecord?, Error?) -> Void
  ) {
    queue.async(flags: .barrier) {
      if let space = self.space, space.decide() {
        completionHandler(nil, MockError.simulated)
        return
      }

      self.records[record.recordID] = record
      completionHandler(record, nil)
    }
  }

  public func save(
    _ zone: CKRecordZone, completionHandler: @escaping (CKRecordZone?, Error?) -> Void
  ) {
    queue.async(flags: .barrier) {
      if let space = self.space, space.decide() {
        completionHandler(nil, MockError.simulated)
        return
      }

      self.recordZones[zone.zoneID] = zone
      completionHandler(zone, nil)
    }
  }

  public func save(
    _ subscription: CKSubscription, completionHandler: @escaping (CKSubscription?, Error?) -> Void
  ) {
    queue.async(flags: .barrier) {
      if let space = self.space, space.decide() {
        completionHandler(nil, MockError.simulated)
        return
      }

      self.subscriptions[subscription.subscriptionID] = subscription
      completionHandler(subscription, nil)
    }
  }
}
