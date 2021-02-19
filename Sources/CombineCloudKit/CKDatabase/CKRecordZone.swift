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
    Future { promise in
      self.save(recordZone) { recordZone, error in
        guard let recordZone = recordZone, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(recordZone))
      }
    }.eraseToAnyPublisher()
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
    let subject = PassthroughSubject<CKRecordZone, Error>()
    let operation = CKModifyRecordZonesOperation(
      recordZonesToSave: recordZones, recordZoneIDsToDelete: nil
    )
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.modifyRecordZonesCompletionBlock = { recordZones, _, error in
      guard let recordZones = recordZones, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for recordZone in recordZones {
        subject.send(recordZone)
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
  }

  public final func deleteAtBackgroundPriority(
    recordZoneID: CKRecordZone.ID
  ) -> AnyPublisher<CKRecordZone.ID, Error> {
    Future { promise in
      self.delete(withRecordZoneID: recordZoneID) { recordZoneID, error in
        guard let recordZoneID = recordZoneID, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(recordZoneID))
      }
    }.eraseToAnyPublisher()
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
    let subject = PassthroughSubject<CKRecordZone.ID, Error>()
    let operation = CKModifyRecordZonesOperation(
      recordZonesToSave: nil, recordZoneIDsToDelete: recordZoneIDs
    )
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.modifyRecordZonesCompletionBlock = { _, recordZoneIDs, error in
      guard let recordZoneIDs = recordZoneIDs, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for recordZoneID in recordZoneIDs {
        subject.send(recordZoneID)
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
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
    let savedSubject = PassthroughSubject<CKRecordZone, Error>()
    let deletedSubject = PassthroughSubject<CKRecordZone.ID, Error>()
    let operation = CKModifyRecordZonesOperation(
      recordZonesToSave: recordZonesToSave, recordZoneIDsToDelete: recordZoneIDsToDelete
    )
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.modifyRecordZonesCompletionBlock = { saved, deleted, error in
      guard error == nil else {
        savedSubject.send(completion: .failure(error!))
        deletedSubject.send(completion: .failure(error!))
        return
      }

      if let saved = saved {
        for record in saved {
          savedSubject.send(record)
        }
      }

      if let deleted = deleted {
        for recordID in deleted {
          deletedSubject.send(recordID)
        }
      }

      savedSubject.send(completion: .finished)
      deletedSubject.send(completion: .finished)
    }

    add(operation)

    return CCKModifyRecordZonePublishers(
      saved: savedSubject.propagateCancellationTo(operation),
      deleted: deletedSubject.propagateCancellationTo(operation)
    )
  }

  public final func fetchAtBackgroundPriority(
    withRecordZoneID recordZoneID: CKRecordZone.ID
  ) -> AnyPublisher<CKRecordZone, Error> {
    Future { promise in
      self.fetch(withRecordZoneID: recordZoneID) { recordZone, error in
        guard let recordZone = recordZone, error == nil else {
          promise(.failure(error!))
          return
        }

        promise(.success(recordZone))
      }
    }.eraseToAnyPublisher()
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
    let subject = PassthroughSubject<CKRecordZone, Error>()
    let operation = CKFetchRecordZonesOperation(recordZoneIDs: recordZoneIDs)
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.fetchRecordZonesCompletionBlock = { recordZones, error in
      guard let recordZones = recordZones, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for recordZone in recordZones.values {
        subject.send(recordZone)
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
  }

  public final func fetchAllRecordZonesAtBackgroundPriority()
    -> AnyPublisher<CKRecordZone, Error>
  {
    let subject = PassthroughSubject<CKRecordZone, Error>()
    fetchAllRecordZones { recordZones, error in
      guard let recordZones = recordZones, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for recordZone in recordZones {
        subject.send(recordZone)
      }

      subject.send(completion: .finished)
    }

    return subject.eraseToAnyPublisher()
  }

  public final func fetchAllRecordZones(
    withConfiguration configuration: CKOperation.Configuration? = nil
  ) -> AnyPublisher<CKRecordZone, Error> {
    let subject = PassthroughSubject<CKRecordZone, Error>()
    let operation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
    if configuration != nil {
      operation.configuration = configuration
    }
    operation.fetchRecordZonesCompletionBlock = { recordZones, error in
      guard let recordZones = recordZones, error == nil else {
        subject.send(completion: .failure(error!))
        return
      }

      for recordZone in recordZones.values {
        subject.send(recordZone)
      }

      subject.send(completion: .finished)
    }

    add(operation)

    return subject.propagateCancellationTo(operation)
  }
}
