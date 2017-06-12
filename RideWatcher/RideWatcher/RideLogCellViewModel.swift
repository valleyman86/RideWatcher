//
//  RideLogCellViewModel.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/9/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class RideLogGPSCellViewModel: RideLogCellViewModel {
    public var viewDelegate: RideLogCellViewModelDelegate?
    var startAddress:String?
    var startTime: String?
    var endAddress:String?
    var endTime: String?
    var tripPath: MKPolyline?
    
    let dateFormatter = DateFormatter()
    
    init(_ trip:Trip) {
        
        guard let startLocation = trip.travelPath.first else {
            return
        }
        
        dateFormatter.timeStyle = .short
        
        startTime = dateFormatter.string(from: startLocation.timestamp)
        
        if let startAddress = trip.startAddress {
            self.startAddress = startAddress
        } else {
            geocodeLocation(location: startLocation) {
                self.startAddress = $0
                trip.startAddress = self.startAddress
                CoreDataUtils.saveContext()
            }
        }
        
        if let endLocation = trip.travelPath.last, trip.completed {
            endTime = dateFormatter.string(from: endLocation.timestamp) + " (" + getTripLength(startTime: startLocation.timestamp, endTime: endLocation.timestamp) + ")"
            
            if let endAddress = trip.endAddress {
                self.endAddress = endAddress
            } else {
                geocodeLocation(location: endLocation) {
                    self.endAddress = $0
                    trip.endAddress = self.endAddress
                    CoreDataUtils.saveContext()
                }
            }
        }
        
        var locations = trip.travelPath.map { $0.coordinate }
        tripPath = MKPolyline(coordinates: &locations, count: locations.count)
    }
    

    func getTripLength(startTime:Date, endTime:Date) -> String {
        let timeDiffComponents = Calendar.current.dateComponents([.minute, .second], from: startTime, to: endTime)
        
        var length = ""
        if let minuteComponent = timeDiffComponents.minute, minuteComponent > 0 {
            length = String(minuteComponent) + "min"
        } else if let secondsComponent = timeDiffComponents.second {
            length = String(secondsComponent) + "sec"
        }
        
        return length
    }
    
    func geocodeLocation(location:CLLocation, getPlacemarkString: @escaping (String) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if let error = error {
                print(error)
            } else {
                if let placemark = placemarks?.last {
                    getPlacemarkString([placemark.subThoroughfare, placemark.thoroughfare].flatMap({$0}).joined(separator:" "))
                    self.viewDelegate?.update()
                }
            }
        })
    }
}
