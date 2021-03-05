//
//  CCKFetchRecordsPublishers.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 3/4/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

/// `Publisher`s returned by `fetch`.
///
/// - Note: Canceling either `Publisher` cancels the underlying `CKFetchRecordsOperation`.
public struct CCKFetchRecordsPublishers {
  /// A `Publisher` that emits percentages of data downloaded for fetched records, or an error if they could not be
  /// fetched.
  ///
  /// - Note: The range is 0.0 to 1.0, where 0.0 indicates that CloudKit hasn’t downloaded anything for the record
  /// with the provided `CKRecord.ID`, and 1.0 means the record download is complete.
  public let progress: AnyPublisher<(CKRecord.ID, Double), Error>

  /// A `Publisher` that emits the `CKRecord`s of the fetched records, or an error if they could not be fetched.
  public let fetched: AnyPublisher<CKRecord, Error>
}
