//
//  Progress.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 4/19/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

/// Represents the completion progress of a `CKRecord` save or fetch operation.
public enum Progress {
  /// Initializes a `Progress` instance from a percentage expressed as a `Double` in the range [0.0, 100.0].
  ///
  /// - Parameters:
  ///   - percent: A `Double` in the range [0.0, 100.0]. Values are clamped to this range.
  /// - Returns: The `Progress`.
  public init(percent: Double) {
    self.init(rawValue: percent / 100.0)
  }

  /// The save or fetch operation is complete.
  case complete

  /// The save or fetch operation is incomplete. `percent` is a value indicating progress in the range \[0.0, 100.0\).
  case incomplete(percent: Double)
}

extension Progress: RawRepresentable {
  public var rawValue: Double {
    switch self {
    case .complete:
      return 1.0
    case .incomplete(let percent):
      return percent / 100.0
    }
  }

  public typealias RawValue = Double

  /// Initializes a `Progress` instance from a percentage expressed as a `Double` in the range [0.0, 1.0].
  ///
  /// - Parameters:
  ///   - percent: A `Double` in the range [0.0, 1.0]. Values are clamped to this range.
  /// - Returns: The `Progress`.
  public init(rawValue: Double) {
    if rawValue >= 1.0 {
      self = .complete
    } else if rawValue >= 0.0 {
      self = .incomplete(percent: rawValue * 100.0)
    } else {
      self = .incomplete(percent: 0.0)
    }
  }
}

extension Progress: Comparable {
  public static func < (left: Progress, right: Progress) -> Bool {
    left.rawValue < right.rawValue
  }
}
