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
  public func save(recordZone: CKRecordZone) -> Future<CKRecordZone, Error> {
    Future { promise in
      self.save(recordZone) { recordZone, error in
        guard let recordZone = recordZone, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(recordZone))
      }
    }
  }

  public func save(
    recordZones: [CKRecordZone]
  ) -> Future<[CKRecordZone], Error> {
    Future { promise in
      let operation = CKModifyRecordZonesOperation(
        recordZonesToSave: recordZones, recordZoneIDsToDelete: nil)
      operation.modifyRecordZonesCompletionBlock = { savedRecordZones, _, error in
        guard error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(savedRecordZones!))
      }

      self.add(operation)
    }
  }

  public func delete(recordZoneID: CKRecordZone.ID) -> Future<CKRecordZone.ID, Error> {
    Future { promise in
      self.delete(withRecordZoneID: recordZoneID) { recordZoneID, error in
        guard let recordZoneID = recordZoneID, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(recordZoneID))
      }
    }
  }

  public func delete(
    recordZoneIDs: [CKRecordZone.ID]
  ) -> Future<[CKRecordZone.ID], Error> {
    Future { promise in
      let operation = CKModifyRecordZonesOperation(
        recordZonesToSave: nil, recordZoneIDsToDelete: recordZoneIDs)
      operation.modifyRecordZonesCompletionBlock = { _, deletedRecordZoneIDs, error in
        guard error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(deletedRecordZoneIDs!))
      }

      self.add(operation)
    }
  }

  public func modify(
    recordZonesToSave: [CKRecordZone]? = nil,
    recordZoneIDsToDelete: [CKRecordZone.ID]? = nil
  ) -> Future<([CKRecordZone]?, [CKRecordZone.ID]?), Error> {
    Future { promise in
      let operation = CKModifyRecordZonesOperation(
        recordZonesToSave: recordZonesToSave, recordZoneIDsToDelete: recordZoneIDsToDelete
      )
      operation.modifyRecordZonesCompletionBlock = {
        savedRecordZones, deletedRecordZoneIDs, error in
        guard error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success((savedRecordZones, deletedRecordZoneIDs)))
      }

      self.add(operation)
    }
  }

  public func fetch(withRecordID recordID: CKRecord.ID) -> Future<CKRecord, Error> {
    Future { promise in
      self.fetch(withRecordID: recordID) { record, error in
        guard let record = record, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(record))
      }
    }
  }

  public func fetch(withRecordZoneID recordZoneID: CKRecordZone.ID) -> Future<CKRecordZone, Error> {
    Future { promise in
      self.fetch(withRecordZoneID: recordZoneID) { recordZone, error in
        guard let recordZone = recordZone, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(recordZone))
      }
    }
  }

  public func fetch(recordZoneIDs: [CKRecordZone.ID]) -> Future<
    [CKRecordZone.ID: CKRecordZone], Error
  > {
    Future { promise in
      let operation = CKFetchRecordZonesOperation(recordZoneIDs: recordZoneIDs)
      operation.fetchRecordZonesCompletionBlock = { zones, error in
        guard let zones = zones, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(zones))
      }

      self.add(operation)
    }
  }

  public func fetchAllRecordZones(withHighPriority: Bool = true) -> Future<
    [CKRecordZone.ID: CKRecordZone], Error
  > {
    Future { promise in
      if withHighPriority {
        let operation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        operation.fetchRecordZonesCompletionBlock = { zones, error in
          guard let zones = zones, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(zones))
        }

        self.add(operation)
      } else {
        // https://developer.apple.com/documentation/cloudkit/ckdatabase/1449112-fetchallrecordzones
        // "The system executes the fetch with a low priority. Use this method when you don’t
        // require the record zones immediately. To fetch record zones with a higher priority,
        // use an instance of CKFetchRecordZonesOperation instead."
        self.fetchAllRecordZones { zones, error in
          guard let zones = zones, error == nil else {
            promise(.failure(error!))
            return
          }

          var zoneIDsToZones = [CKRecordZone.ID: CKRecordZone]()
          zoneIDsToZones.reserveCapacity(zones.count)
          for zone in zones {
            zoneIDsToZones[zone.zoneID] = zone
          }

          promise(.success(zoneIDsToZones))
        }
      }
    }
  }
}
