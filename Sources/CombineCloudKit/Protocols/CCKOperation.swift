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

protocol CCKOperation: Operation {
  var configuration: CKOperation.Configuration! { get set }
}
