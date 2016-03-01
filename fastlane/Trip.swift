//
//  Trip.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/20/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Trip: NSManagedObject {
    
    struct Keys {
        static let TITLE = "title"
        static let LANES = "lanes"
    }
    
    @NSManaged var title: String!
    @NSManaged var traveller: Traveller!
    @NSManaged var lanes: [Lane]!
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(title: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.title = title
        let _ = Lane(latitude: 1.0, longitude: 2.0, lane: 3, trip: self, context: context)
//        lanes.append(lane)
    }
    
    func getLanes() -> [Lane] {
        let fetchRequest = NSFetchRequest(entityName: "Lane")
        let predicate = NSPredicate(format: "trip.title == %@", title)
        fetchRequest.predicate = predicate
        let results = try! managedObjectContext!.executeFetchRequest(fetchRequest)
        return results as! [Lane]
    }
    
    func saveAsDictionary() -> [String: AnyObject!] {
        var lanesAsDic = [[String: AnyObject!]]()
        for lane in getLanes() {
            let laneAdDic = lane.saveAsDictionary()
            lanesAsDic.append(laneAdDic)
        }
        
        let dic: [String: AnyObject!] = [
            Keys.TITLE: title,
            Keys.LANES: lanesAsDic
        ]
        
        return dic
    }

    func save() -> NSData {
        let dic = saveAsDictionary()
        let data = try! NSJSONSerialization.dataWithJSONObject(dic, options: .PrettyPrinted)
        let obj = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        print(obj)
        return data
    }
}