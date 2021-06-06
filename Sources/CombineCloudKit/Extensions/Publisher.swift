//
//  Publisher.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 2/18/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit
import Combine

extension Publisher {
  func propagateCancellationTo(_ operation: CCKOperation) -> AnyPublisher<Output, Failure> {
    handleEvents(receiveCancel: { operation.cancel() }).eraseToAnyPublisher()
  }
}
