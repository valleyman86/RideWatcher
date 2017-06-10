//
//  Trip.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/9/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

@objc(Trip)
public class Trip: NSManagedObject {
    @nonobjc public class func sortedFetchRequest() -> NSFetchRequest<Trip> {
        let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        return fetchRequest
    }
    
    @NSManaged public var travelPath: [CLLocation]
    @NSManaged public var completed: Bool
    @NSManaged public var startTime: Date
    @NSManaged public var startAddress: String?
    @NSManaged public var endAddress: String?
}
