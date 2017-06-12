//
//  RideLogGPSViewModel.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/8/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

class RideLogGPSViewModel: NSObject, RideLogViewModel, GPSTrackerDelegate, NSFetchedResultsControllerDelegate {
    
    public var viewDelegate: RideLogViewModelDelegate?
    public var isLoggingActive: Bool {
        get {
            return gpsTracker != nil ? gpsTracker.isActive : false
        }
    }

    private var fetchedResultsController: NSFetchedResultsController<Trip>!
    private let gpsTracker:GPSTracker!
    private var currentTrip:Trip? // Used to keep track of the trip after it has been started.
    
    init(gpsTracker:GPSTracker) {
        self.gpsTracker = gpsTracker
        
        super.init()
        
        self.gpsTracker.delegate = self
        self.gpsTracker.stopTimeThreshold = 60
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: Trip.sortedFetchRequest(), managedObjectContext: CoreDataUtils.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    
    // MARK: - RideLogViewModel
    
    func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func viewModelForIndexPath(_ indexPath: IndexPath) -> RideLogCellViewModel? {
        guard let trip = self.fetchedResultsController?.object(at: indexPath) else {
            return nil
        }
        
        return RideLogGPSCellViewModel(trip)
    }
    
    func startLogging(_ callback: @escaping (RideLogLogError?) -> Void) {
        gpsTracker.startTracker { (error:LocationDispatcher.AuthorizationError?) in
            if let error = error, case .notAuthorized(let description) = error {
                callback(RideLogLogError.general(description: description))
            } else {
                callback(nil)
            }
        }
    }
    
    func stopLogging() {
        gpsTracker.stopTracker()
    }
    
    // MARK: - GPSTrackerDelegate
    
    func tripBegan(location: CLLocation) {
        currentTrip = Trip(context: CoreDataUtils.persistentContainer.viewContext) // Link Task & Context
        currentTrip?.startTime = location.timestamp
        currentTrip?.travelPath = [location]
        CoreDataUtils.saveContext()
    }
    
    func tripLocationChanged(location: CLLocation) {
        guard let currentTrip = currentTrip else {
            return
        }
        
        currentTrip.travelPath.append(location)
        CoreDataUtils.saveContext()
    }
    
    func tripEnded(location: CLLocation) {
        guard let currentTrip = currentTrip else {
            debugPrint("Somehow this trip ended before it ever started... Time travel most likely.")
            return
        }
        
        currentTrip.travelPath.append(location)
        currentTrip.completed = true
        CoreDataUtils.saveContext()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        viewDelegate?.viewModelWillChangeContent(self)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        // I preferred to be a bit more strict here just for future safety. If I converted one enum to another directly and some other option came
        // back that I did not expect we could crash.
        var changeType:RideLogChangeType
        
        switch type {
            case .insert:
                changeType = .insert
            case .delete:
                changeType = .delete
            case .update:
                changeType = .update
            case .move:
                changeType = .move
        }
    
        viewDelegate?.viewModel(self, didChange: anObject, at: indexPath, for: changeType, newIndexPath: newIndexPath)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        viewDelegate?.viewModelDidChangeContent(self)
    }
    
}
