//
//  RideLogViewModelProtocol.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/8/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import Foundation

enum RideLogChangeType : UInt {
    case insert
    case delete
    case move
    case update
}

/// Delegate protocol used for communicating with the ViewControllers that may use the viewModel
protocol RideLogViewModelDelegate : class {  
    func viewModelWillChangeContent(_ viewModel: RideLogViewModel)
    func viewModel(_ viewModel: RideLogViewModel, didChange anObject: Any, at indexPath: IndexPath?, for type: RideLogChangeType, newIndexPath: IndexPath?)
    func viewModelDidChangeContent(_ viewModel: RideLogViewModel)
}

/// Protocol for loading data from arbitrary objects (i.e. The view is populated by a server rather than location services"
protocol RideLogViewModel {
    weak var viewDelegate:RideLogViewModelDelegate? { get set }
    var isLoggingActive:Bool { get }
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    func viewModelForIndexPath(_ indexPath: IndexPath) -> RideLogCellViewModel?
    func startLogging()
    func stopLogging()
}

extension RideLogViewModel {
    func numberOfSections() -> Int {
        return 1
    }
}
