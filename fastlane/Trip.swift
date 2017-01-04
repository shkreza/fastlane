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
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(title: String, traveller: Traveller!, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Trip", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.title = title
        self.traveller = traveller
//        let _ = Lane(latitude: 1.0, longitude: 2.0, lane: 3, trip: self, context: context)
//        lanes.append(lane)
    }
    
    init(dic: [String: AnyObject?], traveller: Traveller!, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Trip", in: context)!
        super.init(entity: entity, insertInto: context)

        self.title = dic[Keys.TITLE] as! String
        self.traveller = traveller
        
        if let lanesDic = dic[Keys.LANES] as? [[String: AnyObject?]] {
            for laneDic in lanesDic {
                let _ = Lane(dic: laneDic as [String : AnyObject], trip: self, context: context)
            }
        }
    }
    
    func getLanes() -> [Lane] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Lane")
        let predicate = NSPredicate(format: "trip.title == %@", title)
        fetchRequest.predicate = predicate
        let results = try! managedObjectContext!.fetch(fetchRequest)
        return results as! [Lane]
    }
    
    func saveAsDictionary() -> [String: AnyObject?] {
        var lanesAsDic = [[String: AnyObject!]]()
        for lane in getLanes() {
            let laneAdDic = lane.saveAsDictionary()
            lanesAsDic.append(laneAdDic)
        }
        
        let dic: [String: AnyObject?] = [
            Keys.TITLE: title as ImplicitlyUnwrappedOptional<AnyObject>,
            Keys.LANES: lanesAsDic as Optional<AnyObject>
        ]
        
        return dic
    }

    func save() -> Data {
        let dic = saveAsDictionary()
        let data = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        let obj = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        print(obj)
        return data
    }
}
