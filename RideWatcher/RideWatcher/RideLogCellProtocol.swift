//
//  RideLogCellProtocol.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/9/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import Foundation
import CoreLocation

protocol RideLogCellViewModelDelegate : class {
    func update()
}

protocol RideLogCellViewModel {
    weak var viewDelegate:RideLogCellViewModelDelegate? { get set }
    var startLocation:String? { get }
    var startTime:String? { get }
    var endLocation:String? { get }
    var endTime:String? { get }
}
