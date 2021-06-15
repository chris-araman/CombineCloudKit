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
    _ databaseItemsSelector: @escaping (MockDatabase, (inout [ID: T]) -> Void) -> Void,
    _ itemIDs: [ID]?
  ) {
    self.databaseItemsSelector = databaseItemsSelector
    self.itemIDs = itemIDs
    super.init(database)
  }

  public var perItemProgressBlock: ((ID, Double) -> Void)?

  public var perItemCompletionBlock: ((T?, ID?, Error?) -> Void)?

  public var fetchItemsCompletionBlock: (([ID: T]?, Error?) -> Void)?

  public override func start() {
    guard let completion = fetchItemsCompletionBlock else {
      // TODO: XCTFail
      fatalError("fetchItemsCompletionBlock not set.")
    }

    mockDatabase.queue.async {
      self.databaseItemsSelector(self.mockDatabase) { databaseItems in
        if let itemIDs = self.itemIDs {
          guard itemIDs.allSatisfy(databaseItems.keys.contains) else {
            completion(nil, MockError.doesNotExist)
            return
          }
        }

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
            // TODO: Should this return the ID on success?
            completion(item, nil, nil)
          }

          return true
        }

        // TODO: Simulate failures.
        completion(items, nil)
      }
    }
  }
}
