//
//  LaneAnnotation.swift
//  fastlane
//
//  Created by Reza Sherafat on 3/5/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation
import MapKit

class LaneAnnotation: NSObject, MKAnnotation {
    
    let lane: Lane
    
    init(lane: Lane) {
        self.lane = lane
    }
    
    @objc var coordinate: CLLocationCoordinate2D {
        get {
            return lane.coord
        }
    }
}