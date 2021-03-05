//
//  CCKModifyRecordsPublishers.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 3/4/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

/// `Publisher`s returned by `modify`.
///
/// - Note: Canceling either `Publisher` cancels the underlying `CKModifyRecordsOperation`.
public struct CCKModifyRecordsPublishers {
  /// A `Publisher` that emits percentages of data saved for each record, or an error if the records could not be
  /// saved.
  ///
  /// - Note: The range is 0.0 to 1.0, where 0.0 indicates that CloudKit hasn’t saved any data for the record
  /// with the provided `CKRecord.ID`, and 1.0 means that CloudKit has saved the entire record.
  public let progress: AnyPublisher<(CKRecord, Double), Error>

  /// A `Publisher` that emits the `CKRecord`s of the saved records, or an error if they could not be saved.
  public let saved: AnyPublisher<CKRecord, Error>

  /// A `Publisher` that emits the `CKRecord.ID`s of the deleted records, or an error if they could not be deleted.
  public let deleted: AnyPublisher<CKRecord.ID, Error>
}
