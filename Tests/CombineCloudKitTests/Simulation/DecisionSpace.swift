//
//  CKContainerTests.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/16/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

/// Provides logic to exhaustively search a decision space.
/// - SeeAlso: [rseq](https://qumulo.com/blog/making-100-code-coverage-as-easy-as-flipping-a-coin/)
class DecisionSpace {
  var space = [Bool]()
  var index = [Bool].Index()

  func decide() -> Bool {
    if index == space.endIndex {
      space.append(false)
    }

    let decision = space[index]
    index += 1

    return decision
  }

  func decidedAffirmatively() -> Bool {
    space.contains(true)
  }

  func reset() -> Bool {
    index = [Bool].Index()

    guard let lastFalse = space.lastIndex(of: false) else {
      // We have exhausted the decision space.
      space.removeAll()
      return false
    }

    space.removeLast(space.endIndex - lastFalse - 1)
    space[lastFalse] = true
    return true
  }
}
