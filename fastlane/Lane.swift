//
//  Lane.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/29/16.
//  Copyright © 2016 No org. All rights reserved.
//

import CoreData
import Foundation
import MapKit

class Lane: NSManagedObject {
    
    struct Keys {
        static let LATITUDE = "latitude"
        static let LONGITUDE = "longitude"
        static let LANE = "lane"
    }
    
    @NSManaged var latitude: NSNumber!
    @NSManaged var longitude: NSNumber!
    @NSManaged var lane: NSNumber!
    
    @NSManaged var trip: Trip!
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude: Double, longitude: Double, lane: Int, trip: Trip, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Lane", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
        self.trip = trip
        self.lane = lane
    }
    
    init(dic: [String: AnyObject], trip: Trip, context: NSManagedObjectContext?) {
        let entity = NSEntityDescription.entityForName("Lane", inManagedObjectContext: context!)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.trip = trip
        self.lane = dic[Keys.LANE] as! NSNumber
        self.latitude = dic[Keys.LATITUDE] as! Double
        self.longitude = dic[Keys.LONGITUDE] as! Double
    }
    
    lazy var coord: CLLocationCoordinate2D = {
        return CLLocationCoordinate2D(latitude: self.latitude as Double, longitude: self.longitude as Double)
    }()
    
    func saveAsDictionary() -> [String: AnyObject!] {
        let dic = [
            Keys.LANE: lane,
            Keys.LATITUDE: latitude,
            Keys.LONGITUDE: longitude
        ]
        
        return dic // as! [String : AnyObject!]
    }
}