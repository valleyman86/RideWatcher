//
//  AppDelegate.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/5/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Usually one might set a default storyboard and initial view in said storyboard but in my case
        // I want to support some dependency injection and I need access to the initial view controller.
        // Also if we had some onboarding we could set that up here now if we wanted too...
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Initialize the first view controller with a view model
        let initialViewController = storyboard.instantiateInitialViewController()
        if let rideLogViewController = initialViewController as? RideLogViewController
            ?? (initialViewController as? UINavigationController)?.viewControllers.first as? RideLogViewController {
            
            rideLogViewController.viewModel = RideLogGPSViewModel(gpsTracker: GPSTracker(locationDispatcher:LocationDispatcher.shared))
        }
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        
        // If a trip has been started and not completed but the app has been force quit/crashed then complete it.
        do {
            if let trips = try CoreDataUtils.persistentContainer.viewContext.fetch(Trip.fetchRequest()) as? [Trip] {
                for trip in trips {
                    if (!trip.completed) {
                        trip.completed = true
                    }
                }
                CoreDataUtils.saveContext()
            }
        } catch {
            print("Fetching Failed")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataUtils.saveContext()
    }
}

