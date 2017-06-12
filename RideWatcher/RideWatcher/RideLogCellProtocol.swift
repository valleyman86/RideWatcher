//
//  RideLogCellProtocol.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/9/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit


/// Delegate for letting teh viewModel communicate back to the cell
protocol RideLogCellViewModelDelegate : class {
    func update()
}


/// Ride Log Cell View Model for loading data into cell.
protocol RideLogCellViewModel {
    weak var viewDelegate:RideLogCellViewModelDelegate? { get set }
    var startAddress:String? { get }
    var startTime:String? { get }
    var endAddress:String? { get }
    var endTime:String? { get }
    var tripPath: MKPolyline? { get }
}
