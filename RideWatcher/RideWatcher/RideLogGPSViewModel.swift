//
//  RideLogGPSViewModel.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/8/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import Foundation
import CoreLocation

class RideLogGPSViewModel: RideLogViewModel, GPSTrackerDelegate {
    
    public var viewDelegate: RideLogViewModelDelegate?
    
    private var trips = [(start:CLLocation, end:CLLocation?)]()
    private let gpsTracker:GPSTracker!
    
    init(gpsTracker:GPSTracker) {
        self.gpsTracker = gpsTracker
        self.gpsTracker.delegate = self
        self.gpsTracker.stopTimeThreshold = 2
    }
    
    
    // MARK: - RideLogViewModel
    
    func numberOfRowsInSection(section: Int) -> Int {
        return trips.count
    }
    
    func viewModelForIndexPath(_ indexPath: IndexPath) -> RideLogCellViewModel? {
        guard trips.startIndex != trips.endIndex else {
            return nil
        }
        
        // Reverse the array so that latest trips are at the top
        let index = (trips.endIndex - 1) - indexPath.row
        return RideLogGPSCellViewModel(startLocation:trips[index].start, endLocation:trips[index].end)
    }
    
    func startLogging() {
        self.gpsTracker.startTracker { (error:LocationDispatcher.AuthorizationError?) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func stopLogging() {
        
    }
    
    // MARK: - GPSTrackerDelegate
    
    func tripBegan(location: CLLocation) {
        trips.append((start: location, end: nil))
        self.viewDelegate?.update()
    }
    
    func tripLocationChanged(location: CLLocation) {
        // Ignored for future feature
    }
    
    func tripEnded(location: CLLocation) {
        guard var lastTrip = trips.last, lastTrip.end == nil else {
            debugPrint("Somehow this trip ended before it ever started... Time travel most likely.")
            return
        }
        
        lastTrip.end = location
        trips.removeLast()
        trips.append(lastTrip)
        
        self.viewDelegate?.update()
    }
}
