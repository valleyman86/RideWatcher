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
    private var currentTrip:Trip?
    
    init(gpsTracker:GPSTracker) {
        self.gpsTracker = gpsTracker
        
        super.init()
        
        self.gpsTracker.delegate = self
        self.gpsTracker.stopTimeThreshold = 2
        
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
    
    func startLogging() {
        gpsTracker.startTracker { (error:LocationDispatcher.AuthorizationError?) in
            if let error = error {
                print(error)
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
        
        self.viewDelegate?.update()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
        viewDelegate?.update()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            tableView.insertRows(at: [newIndexPath!], with: .fade)
//        case .delete:
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//        case .update:
//            tableView.reloadRows(at: [indexPath!], with: .fade)
//        case .move:
//            tableView.moveRow(at: indexPath!, to: newIndexPath!)
//        }
        viewDelegate?.update()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
        viewDelegate?.update()
    }
    
}
