//
//  LocationDispatcher.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/7/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationDispatcherDelegate : class {
    var isActive: Bool { get set }
    func locationDispatcher(didUpdateLocation lastLocation: CLLocation)
    func locationManager(didChangeAuthorization status: CLAuthorizationStatus)
    
}

/// LocationDispatcher is manages dispatching location events to other objects.
/// There is only one GPS unit on a devices so it is using a singleton model.
class LocationDispatcher: NSObject, CLLocationManagerDelegate {
    
    public static let shared = LocationDispatcher()
    
    public var locationTimeOut = 5.0
    
    /// The mode of operation for location services.
    ///
    /// - authorizedAlways: User has granted authorization to use their location at any time, 
    ///                     including monitoring for regions, visits, or significant location changes.
    /// - authorizedWhenInUse: User has granted authorization to use their location only when your app
    ///                        is visible to them (it will be made visible to them if you continue to
    ///                        receive location updates while in the background).  Authorization to use
    ///                        launch APIs has not been granted.
    public enum Mode {
        case authorizedAlways
        case authorizedWhenInUse
    }
    
    /// Error description for unauthorized access to location services
    ///
    /// - notAuthorized: user has disabled some or all of location services that were requested. (description: human readable string explaining the issue)
    public enum AuthorizationError: Error {
        case notAuthorized(description: String)
    }
    
    
    /// WeakContainer is used to store a weak pointer to a LocationDispatcherDelegate. Kinda like a single delegate
    /// we don't need to store a strong pointer allowing objects observing location updates to deinit as usual. This also
    /// allows sort of automatic cleanup of the objects from this class if they deinit. 
    /// Note: I chose to not use generics for this for the simple reason of type safetly. You can't use a protocol in a generic on "AnyObject" which
    ///       was required to use a weak pointer. I could have not used the protocol as the type and instead used AnyObject but no thanks... It is private because
    ///       it doesn't need to leave the scope of this class.
    private struct WeakContainer : Hashable {
        weak var value: LocationDispatcherDelegate?
        
        var hashValue: Int {
            if let value = value {
                return ObjectIdentifier(value).hashValue
            }
            
            return 0
        }
        
        static func == (lhs: WeakContainer, rhs: WeakContainer) -> Bool {
            return lhs.value === rhs.value
        }
    }
    
    private let locationManager =  CLLocationManager()
    private var triedAlwaysOnce = false //.requestAlwaysAuthorization can only be called once if the current mode is authorizedWhenInUse
    private var callback:((AuthorizationError?) -> Void)? // used for the async auth update in CLLocationManager
    private var locationDelegates = Set<WeakContainer>() // Unique delegates for sending location updates.
    
    private override init() {
        super.init()
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
    }
    
    
    /// Starts the dispatcher and authorizes access to location services if necessary.
    ///
    /// - Parameters:
    ///   - mode: mode to start location services in
    ///   - callback: closure for use in async update of authorization status.
    public func startDispatcher(mode: Mode, callback: @escaping (AuthorizationError?) -> Void) {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways:
                locationManager.startUpdatingLocation()
                callback(nil);
                
            case .notDetermined:
                self.callback = callback;
                if (mode == .authorizedAlways) {
                    locationManager.requestAlwaysAuthorization()
                } else {
                    locationManager.requestWhenInUseAuthorization()
                }
            
            case .authorizedWhenInUse:
                if (mode == .authorizedAlways) {
                    // As per apple docs .requestAlwaysAuthorization can only be called once if the current state is authorizedWhenInUse. I am 
                    // just making sure this is the case (not that it hurts anything) but I can return an error if I know we tried this already.
                    if (!triedAlwaysOnce) {
                        triedAlwaysOnce = true
                        self.callback = callback;
                        locationManager.requestAlwaysAuthorization()
                    } else {
                        callback(.notAuthorized(description: "Unable to start location services to always authorized."));
                    }
                } else {
                    locationManager.startUpdatingLocation()
                    callback(nil);
                }
                
            case .restricted, .denied:
                callback(.notAuthorized(description: "Access to location services is restricted."))
        }
    }
    
    public func addDelegate(delegate: LocationDispatcherDelegate) {
        locationDelegates.insert(WeakContainer(value: delegate))
        
        // Start the dispatcher if we have at least one delegate
        if (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
        }
    }
    
    public func removeDelegate(delegate: LocationDispatcherDelegate) {
        locationDelegates.remove(WeakContainer(value: delegate))
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            manager.startUpdatingLocation()
            
            if let callback = callback {
                callback(nil)
                self.callback = nil // We dont need the callback hanging around after we use it.
            }
        } else if status != .notDetermined {
            if let callback = callback {
                callback(.notAuthorized(description: "Unable to start the location services"))
                self.callback = nil // We dont need the callback hanging around after we use it.
            }
        }
        
        for delegate in locationDelegates {
            delegate.value?.locationManager(didChangeAuthorization: status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Only use the last location if it is less than 5 seconds old.
        guard let lastLocation = locations.last, abs(lastLocation.timestamp.timeIntervalSinceNow) < locationTimeOut else {
            return
        }
        
        
        let activeDelegates = locationDelegates.filter { (locationContainer:WeakContainer) -> Bool in
            if let delegate = locationContainer.value {
                return delegate.isActive
            } else {
                return false
            }
        }
        
        // We don't want to run the location services if we have nothing that cares about it.
        if (activeDelegates.count == 0) {
            manager.stopUpdatingLocation()
        }
        
        // Update all the delegates.
        for delegateContainer in locationDelegates.reversed() {
            if let delegate = delegateContainer.value {
                if (delegate.isActive) {
                    delegate.locationDispatcher(didUpdateLocation: lastLocation)
                }
            } else {
                locationDelegates.remove(delegateContainer)
            }
        }
        
        print(lastLocation)
    }
}
