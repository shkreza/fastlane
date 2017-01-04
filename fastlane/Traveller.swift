//
//  Traveller.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/20/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation
import CoreData
import Google

class Traveller: NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let NAME = "name"
        static let TRIPS = "trips"
    }
    
    @NSManaged var id: String
    @NSManaged var name: String!
    @NSManaged var token: String!
    @NSManaged var accessToken: String!
    
    @NSManaged var trips: [Trip]!
    
    var context: NSManagedObjectContext!
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
        self.context = context
    }
    
    init(user: GIDGoogleUser, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Traveller", in: context)
        super.init(entity: entity!, insertInto: context)
        
        self.context = context
        
        id = user.userID
        name = user.profile.name
        token = user.authentication.idToken!
        accessToken = user.authentication.accessToken
    }
    
    func getTrips() -> [Trip] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Trip")
        let predicate = NSPredicate(format: "traveller.id == %@", id)
        fetchRequest.predicate = predicate
        let results = try! context!.fetch(fetchRequest)
        return results as! [Trip]
    }
    
    func saveAsDictionary() -> [String: AnyObject?] {
        var tripsDic = [[String: AnyObject]]()
        let trips = getTrips()
        for trip in trips {
                let tripAsDic = trip.saveAsDictionary()
                tripsDic.append(tripAsDic as [String : AnyObject])
        }
        
        let dic: [String: AnyObject?] = [
            Keys.ID: id as ImplicitlyUnwrappedOptional<AnyObject>,
            Keys.NAME: name as Optional<AnyObject>,
            Keys.TRIPS: tripsDic as Optional<AnyObject>
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
    
    func loadTrips(_ dic: [String: AnyObject]) -> Bool {
        guard let id = dic[Keys.ID] as? String, id == self.id else {
            return false
        }
        
        if let tripDics = dic[Keys.TRIPS] as? [[String: AnyObject?]] {
            for tripDic in tripDics {
                let _ = Trip(dic: tripDic, traveller: self, context: self.managedObjectContext!)
            }
            return true
        } else {
            return false
        }
    }
}
