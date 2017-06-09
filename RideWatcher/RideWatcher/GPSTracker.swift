//
//  GPSTracker.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/6/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import UIKit
import CoreLocation

protocol GPSTrackerDelegate : class {
    func tripBegan(location:CLLocation) -> Void
    func tripLocationChanged(location:CLLocation) -> Void
    func tripEnded(location:CLLocation) -> Void
}

class GPSTracker: LocationDispatcherDelegate {

    /// Initial speed to start logging a trip in m/s (meters per second). Default: 4.4704 m/s (~10 MPH)
    public var speedThreshold = 4.4704
    
    /// Time period we need to be standing still to stop logging a trip
    public var stopTimeThreshold = 60.0
    
    public weak var delegate:GPSTrackerDelegate?
    
    internal var isActive = false
    
    private let locationDispatcher:LocationDispatcher!
    private let geoLocator = CLGeocoder()
    private var tripStarted = false
    private var dateWhenStopped = Date()
    private var lastLocation:CLLocation?

    
    init(locationDispatcher:LocationDispatcher) {        
        self.locationDispatcher = locationDispatcher
        self.locationDispatcher.addDelegate(delegate: self)
    }
    
    
    /// Starts the tracker
    ///
    /// - Throws: throws if unable
    public func startTracker(callback: @escaping (LocationDispatcher.AuthorizationError?) -> Void) {
        locationDispatcher.startDispatcher(mode: .authorizedAlways) { [weak self] (error:LocationDispatcher.AuthorizationError?)  in
            if (error == nil) {
                self?.isActive = true
            }
            
            callback(error)
        }
    }
    
    public func stopTracker() {
        isActive = false
        if let lastLocation = lastLocation {
            stopTrip(location: lastLocation)
        }
    }
    
    private func startTrip(location:CLLocation) {
        if (!tripStarted) {
            tripStarted = true
            dateWhenStopped = Date()
            delegate?.tripBegan(location: location)
            print("🚙 Started Trip")
        }
    }
    
    private func stopTrip(location:CLLocation) {
        if (tripStarted) {
            tripStarted = false
            delegate?.tripEnded(location: location)
            lastLocation = nil
            print("🚗 Stopped Trip")
        }
    }
    
    // MARK: - LocationDispatcherDelegate
    
    func locationDispatcher(didUpdateLocation lastLocation: CLLocation) {
        if !tripStarted && lastLocation.speed >= speedThreshold {
            startTrip(location: lastLocation)
        }
        
        if tripStarted {
            if lastLocation.speed >= speedThreshold {
                dateWhenStopped = Date()
            }
            
            if abs(dateWhenStopped.timeIntervalSinceNow) > stopTimeThreshold {
                stopTrip(location: lastLocation)
            } else {
                self.lastLocation = lastLocation
                delegate?.tripLocationChanged(location: lastLocation)
            }
        }
    }
}
