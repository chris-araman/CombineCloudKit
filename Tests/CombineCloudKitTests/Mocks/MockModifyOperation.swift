//
//  MockModifyOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

@testable import CombineCloudKit

public class MockModifyOperation<T, ID>: MockDatabaseOperation where ID: Hashable {
  let databaseItemsSelector: (MockDatabase, (inout [ID: T]) -> Void) -> Void
  let id: (T) -> ID
  let itemsToSave: [T]?
  let itemIDsToDelete: [ID]?

  init(
    _ database: MockDatabase,
    _ databaseItemsSelector: @escaping (MockDatabase, (inout [ID: T]) -> Void) -> Void,
    _ id: @escaping (T) -> ID,
    _ itemsToSave: [T]? = nil,
    _ itemIDsToDelete: [ID]? = nil
  ) {
    self.databaseItemsSelector = databaseItemsSelector
    self.id = id
    self.itemsToSave = itemsToSave
    self.itemIDsToDelete = itemIDsToDelete
    super.init(database)
  }

  var modifyItemsCompletionBlock: (([T]?, [ID]?, Error?) -> Void)?
  var perItemCompletionBlock: ((T, Error?) -> Void)?

  public override func start() {
    guard let completion = self.modifyItemsCompletionBlock else {
      // TODO: XCTFail
      fatalError("modifyItemsCompletionBlock not set.")
    }

    mockDatabase.queue.async(flags: .barrier) {
      self.databaseItemsSelector(self.mockDatabase) { databaseItems in
        if let itemIDsToDelete = self.itemIDsToDelete {
          guard itemIDsToDelete.allSatisfy(databaseItems.keys.contains) else {
            completion(nil, nil, MockError.doesNotExist)
            return
          }

          // TODO: What happens if the caller saves and deletes the same record zone?
          for itemID in itemIDsToDelete {
            databaseItems.removeValue(forKey: itemID)
          }
        }

        if let itemsToSave = self.itemsToSave {
          for item in itemsToSave {
            // TODO: What happens if the caller saves two different items with the same ID?
            let id = self.id(item)
            databaseItems[id] = item

            if let perItemCompletion = self.perItemCompletionBlock {
              // TODO: Simulate failures.
              perItemCompletion(item, nil)
            }
          }
        }

        // TODO: Simulate failures.
        completion(self.itemsToSave, self.itemIDsToDelete, nil)
      }
    }
  }
}
