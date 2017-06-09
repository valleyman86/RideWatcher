//
//  RideLogCellViewModel.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/9/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import Foundation
import CoreLocation

class RideLogGPSCellViewModel: RideLogCellViewModel {
    public var viewDelegate: RideLogCellViewModelDelegate?
    var startLocation:String?
    var startTime: String?
    var endLocation:String?
    var endTime: String?
    
    let dateFormatter = DateFormatter()
    
    init(startLocation:CLLocation, endLocation:CLLocation?) {
        
//        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        startTime = dateFormatter.string(from: startLocation.timestamp)
        geocodeLocation(location: startLocation) {
            self.startLocation = $0
        }
        
        if let endLocation = endLocation {
            endTime = dateFormatter.string(from: endLocation.timestamp) + " (" + getTripLength(startTime: startLocation.timestamp, endTime: endLocation.timestamp) + ")"
            geocodeLocation(location: endLocation) {
                self.endLocation = $0
            }
        }
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
