//
//  CCKModifyRecordZonesPublishers.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 3/4/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

/// `Publisher`s returned by `modify`.
///
/// - Note: Canceling either `Publisher` cancels the underlying `CKModifyRecordZonesOperation`.
public struct CCKModifyRecordZonesPublishers {
  /// A `Publisher` that emits the saved `CKRecordZone`s, or an error if they could not be saved.
  public let saved: AnyPublisher<CKRecordZone, Error>

  /// A `Publisher` that emits the deleted `CKRecordZone.ID`s, or an error if they could not be deleted.
  public let deleted: AnyPublisher<CKRecordZone.ID, Error>
}
