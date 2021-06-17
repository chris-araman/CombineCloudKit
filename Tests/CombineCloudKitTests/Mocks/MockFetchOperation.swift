//
//  MockFetchOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/12/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import CombineCloudKit

public class MockFetchOperation<T, ID>: MockDatabaseOperation where ID: Hashable {
  let databaseItemsSelector: (MockDatabase, (inout [ID: T]) -> Void) -> Void
  let itemIDs: [ID]?

  init(
    _ database: MockDatabase,
    _ space: DecisionSpace?,
    _ databaseItemsSelector: @escaping (MockDatabase, (inout [ID: T]) -> Void) -> Void,
    _ itemIDs: [ID]?
  ) {
    self.databaseItemsSelector = databaseItemsSelector
    self.itemIDs = itemIDs
    super.init(database, space)
  }

  public var perItemProgressBlock: ((ID, Double) -> Void)?

  public var perItemCompletionBlock: ((T?, ID?, Error?) -> Void)?

  public var fetchItemsCompletionBlock: (([ID: T]?, Error?) -> Void)?

  public override func start() {
    let completion = try! XCTUnwrap(self.fetchItemsCompletionBlock)
    mockDatabase.queue.async {
      if let space = self.space, space.decide() {
        completion(nil, MockError.simulated)
        return
      }

      self.databaseItemsSelector(self.mockDatabase) { databaseItems in
        if let itemIDs = self.itemIDs {
          guard itemIDs.allSatisfy(databaseItems.keys.contains) else {
            completion(nil, MockError.doesNotExist)
            return
          }
        }

        var perItemError: MockError?
        let items = databaseItems.filter { itemID, item in
          if let itemIDs = self.itemIDs {
            guard itemIDs.contains(itemID) else {
              return false
            }
          }

          if let progress = self.perItemProgressBlock {
            progress(itemID, 0.7)
            progress(itemID, 1.0)
          }

          if let completion = self.perItemCompletionBlock {
            if let space = self.space, space.decide() {
              perItemError = MockError.simulated
              completion(nil, itemID, perItemError)
              return false
            } else {
              completion(item, itemID, nil)
            }
          }

          return true
        }

        guard perItemError == nil else {
          completion(nil, perItemError)
          return
        }

        completion(items, nil)
      }
    }
  }
}
