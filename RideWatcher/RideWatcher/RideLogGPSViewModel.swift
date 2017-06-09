//
//  RideLogGPSViewModel.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/8/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import Foundation

struct RideLogGPSViewModel: RideLogViewModel {
    let gpsTracker:GPSTracker!
    
    init(gpsTracker:GPSTracker) {
        self.gpsTracker = gpsTracker
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return 3
    }
}
