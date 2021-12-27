//
//  MockModifyOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import XCTest

@testable import CombineCloudKit

public class MockModifyOperation<T, ID>: MockDatabaseOperation where ID: Hashable {
  let databaseItemsSelector: (MockDatabase, (inout [ID: T]) -> Void) -> Void
  let id: (T) -> ID
  let itemsToSave: [T]?
  let itemIDsToDelete: [ID]?

  init(
    _ database: MockDatabase,
    _ space: DecisionSpace?,
    _ databaseItemsSelector: @escaping (MockDatabase, (inout [ID: T]) -> Void) -> Void,
    _ id: @escaping (T) -> ID,
    _ itemsToSave: [T]? = nil,
    _ itemIDsToDelete: [ID]? = nil
  ) {
    self.databaseItemsSelector = databaseItemsSelector
    self.id = id
    self.itemsToSave = itemsToSave
    self.itemIDsToDelete = itemIDsToDelete
    super.init(database, space)
  }

  var modifyItemsCompletionBlock: (([T]?, [ID]?, Error?) -> Void)?
  var perItemCompletionBlock: ((T, Error?) -> Void)?

  // TODO: Support atomicity.
  public override func start() {
    let completion = try! XCTUnwrap(self.modifyItemsCompletionBlock)
    mockDatabase.queue.async {
      if let space = self.space, space.decide() {
        completion(nil, nil, MockError.simulated)
        return
      }

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
              if let space = self.space, space.decide() {
                perItemCompletion(item, MockError.simulated)
              } else {
                perItemCompletion(item, nil)
              }
            }
          }
        }

        completion(self.itemsToSave, self.itemIDsToDelete, nil)
      }
    }
  }
}
