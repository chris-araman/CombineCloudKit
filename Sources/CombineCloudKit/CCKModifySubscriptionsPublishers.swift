//
//  CCKModifySubscriptionsPublishers.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 3/4/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

/// `Publisher`s returned by `modify`.
///
/// - Note: Canceling either `Publisher` cancels the underlying `CKModifySubscriptionsOperation`.
public struct CCKModifySubscriptionsPublishers {
  /// Emits the saved `CKSubscription`s, or an error if CombineCloudKit can't save them.
  public let saved: AnyPublisher<CKSubscription, Error>

  /// Emits the deleted `CKSubscriptionID`s, or an error if CombineCloudKit can't delete them.
  public let deleted: AnyPublisher<CKSubscription.ID, Error>
}
