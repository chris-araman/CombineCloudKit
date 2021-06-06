//
//  CCKOperation.swift
//  CombineCloudKit
//
//  Created by Chris Araman on 6/6/21.
//  Copyright © 2021 Chris Araman. All rights reserved.
//

import CloudKit

extension CKOperation: CCKOperation {
}

protocol CCKOperation: AnyObject {
  var configuration: CKOperation.Configuration! { get set }

  func start()
  func cancel()
}
