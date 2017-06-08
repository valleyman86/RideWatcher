//
//  WeakObject.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/7/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import Foundation

struct WeakObject<T: AnyObject> {
    weak var value : T?
    init (_ value: T) {
        self.value = value
    }
}
