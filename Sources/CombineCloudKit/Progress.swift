//
//  Progress.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 4/19/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

/// Represents the completion progress of a `CKRecord` save or fetch operation.
public enum Progress {
  /// The save or fetch operation is complete.
  case complete

  /// The save or fetch operation is incomplete. `percent` is a value indicating progress between unstarted (0.0) and complete (1.0), exclusive.
  case incomplete(percent: Double)
}
