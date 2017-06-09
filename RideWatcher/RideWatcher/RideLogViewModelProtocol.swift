//
//  RideLogViewModelProtocol.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/8/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import Foundation

protocol RideLogViewModel {
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
}

extension RideLogViewModel {
    func numberOfSections() -> Int {
        return 1
    }
}
