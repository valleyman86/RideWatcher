//
//  GPSTracker.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/6/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import UIKit
import CoreLocation

class GPSTracker: LocationDispatcherDelegate {

    /// Initial speed to start logging a trip in m/s (meters per second). Default: 4.4704 m/s (~10 MPH)
    public var speedThreshold = 4.4704
    
    /// Time period we need to be standing still to stop logging a trip
    public var stopTimeThreshold = 60.0
    
    
    internal var isActive = false
    
    private let locationDispatcher:LocationDispatcher!
    private let geoLocator = CLGeocoder()
//    private var isTracking = false
    private var tripStarted = false
    private var dateWhenStopped = Date()
    

    
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
    }
    
    private func startTrip() {
        tripStarted = true
        dateWhenStopped = Date()
        print("🚙 Started Trip")
    }
    
    private func stopTrip() {
        tripStarted = false
        print("🚗 Stopped Trip")
    }
    
    // MARK: - LocationDispatcherDelegate
    
    func locationDispatcher(didUpdateLocation lastLocation: CLLocation) {
        if !tripStarted && lastLocation.speed >= speedThreshold {
            startTrip()
        }
        
        if tripStarted {
            if lastLocation.speed >= speedThreshold {
                dateWhenStopped = Date()
            }
            
            if abs(dateWhenStopped.timeIntervalSinceNow) > stopTimeThreshold {
                stopTrip()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if isActive && (status == .authorizedAlways || status == .authorizedWhenInUse) {
            manager.startUpdatingLocation()
        } else if status != .notDetermined {
            stopTracker()
        }
    }
    
}
