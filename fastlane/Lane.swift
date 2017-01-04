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
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("***: \(latitude) - \(longitude)")
    }
    
    init(coord: CLLocationCoordinate2D, lane: Int, trip: Trip, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Lane", in: context)
        super.init(entity: entity!, insertInto: context)
        
        self.latitude = coord.latitude as NSNumber!
        self.longitude = coord.longitude as NSNumber!
        self.trip = trip
        self.lane = lane as NSNumber!
        print("+++: \(latitude) - \(longitude)")
    }
    
    init(latitude: Double, longitude: Double, lane: Int, trip: Trip, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Lane", in: context)
        super.init(entity: entity!, insertInto: context)
        
        self.latitude = latitude as NSNumber!
        self.longitude = longitude as NSNumber!
        self.trip = trip
        self.lane = lane as NSNumber!
        print("---: \(latitude) - \(longitude)")
    }
    
    init(dic: [String: AnyObject], trip: Trip, context: NSManagedObjectContext?) {
        let entity = NSEntityDescription.entity(forEntityName: "Lane", in: context!)
        super.init(entity: entity!, insertInto: context)
        
        self.trip = trip
        self.lane = dic[Keys.LANE] as! NSNumber
        self.latitude = dic[Keys.LATITUDE] as! Double as NSNumber!
        self.longitude = dic[Keys.LONGITUDE] as! Double as NSNumber!
        print(">>>: \(latitude) - \(longitude)")
    }
    
    lazy var coord: CLLocationCoordinate2D = {
        return CLLocationCoordinate2D(latitude: self.latitude as Double, longitude: self.longitude as Double)
    }()
    
    func saveAsDictionary() -> [String: AnyObject?] {
        let dic = [
            Keys.LANE: lane,
            Keys.LATITUDE: latitude,
            Keys.LONGITUDE: longitude
        ]
        
        return dic // as! [String : AnyObject!]
    }
}
