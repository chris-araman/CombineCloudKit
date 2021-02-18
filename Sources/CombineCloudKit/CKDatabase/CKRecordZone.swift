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
  public func save(
    recordZone: CKRecordZone,
    withHighPriority: Bool = true
  ) -> Future<CKRecordZone, Error> {
    Future { promise in
      if withHighPriority {
        let operation = CKModifyRecordZonesOperation(
          recordZonesToSave: [recordZone], recordZoneIDsToDelete: nil)
        operation.modifyRecordZonesCompletionBlock = { savedRecordZones, _, error in
          guard let savedRecordZone = savedRecordZones?.first, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(savedRecordZone))
        }

        self.add(operation)
      } else {
        self.save(recordZone) { recordZone, error in
          guard let recordZone = recordZone, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(recordZone))
        }
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
        guard let savedRecordZones = savedRecordZones, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(savedRecordZones))
      }

      self.add(operation)
    }
  }

  public func delete(
    recordZoneID: CKRecordZone.ID,
    withHighPriority: Bool = true
  ) -> Future<CKRecordZone.ID, Error> {
    Future { promise in
      if withHighPriority {
        let operation = CKModifyRecordZonesOperation(
          recordZonesToSave: nil, recordZoneIDsToDelete: [recordZoneID])
        operation.modifyRecordZonesCompletionBlock = { _, deletedRecordZoneIDs, error in
          guard let deletedRecordZoneID = deletedRecordZoneIDs?.first, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(deletedRecordZoneID))
        }

        self.add(operation)
      } else {
        self.delete(withRecordZoneID: recordZoneID) { recordZoneID, error in
          guard let recordZoneID = recordZoneID, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(recordZoneID))
        }
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
        guard let deletedRecordZoneIDs = deletedRecordZoneIDs, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(deletedRecordZoneIDs))
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

  public func fetch(
    withRecordZoneID recordZoneID: CKRecordZone.ID,
    withHighPriority: Bool = true
  ) -> Future<CKRecordZone, Error> {
    Future { promise in
      if withHighPriority {
        let operation = CKFetchRecordZonesOperation(recordZoneIDs: [recordZoneID])
        operation.fetchRecordZonesCompletionBlock = { recordZones, error in
          guard let recordZone = recordZones?.first?.value, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(recordZone))
        }

        self.add(operation)
      } else {
        self.fetch(withRecordZoneID: recordZoneID) { recordZone, error in
          guard let recordZone = recordZone, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(recordZone))
        }
      }
    }
  }

  public func fetch(
    recordZoneIDs: [CKRecordZone.ID]
  ) -> Future<[CKRecordZone.ID: CKRecordZone], Error> {
    Future { promise in
      let operation = CKFetchRecordZonesOperation(recordZoneIDs: recordZoneIDs)
      operation.fetchRecordZonesCompletionBlock = { recordZones, error in
        guard let recordZones = recordZones, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(recordZones))
      }

      self.add(operation)
    }
  }

  public func fetchAllRecordZones(
    withHighPriority: Bool = true
  ) -> Future<[CKRecordZone.ID: CKRecordZone], Error> {
    Future { promise in
      if withHighPriority {
        let operation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        operation.fetchRecordZonesCompletionBlock = { recordZones, error in
          guard let recordZones = recordZones, error == nil else {
            promise(.failure(error!))
            return
          }

          promise(.success(recordZones))
        }

        self.add(operation)
      } else {
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
