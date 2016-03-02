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
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.context = context
    }
    
    init(user: GIDGoogleUser, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Traveller", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.context = context
        
        id = user.userID
        name = user.profile.name
        token = user.authentication.idToken!
        accessToken = user.authentication.accessToken
    }
    
    func getTrips() -> [Trip] {
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        let predicate = NSPredicate(format: "traveller.id == %@", id)
        fetchRequest.predicate = predicate
        let results = try! context!.executeFetchRequest(fetchRequest)
        return results as! [Trip]
    }
    
    func saveAsDictionary() -> [String: AnyObject!] {
        var tripsDic = [[String: AnyObject]]()
        let trips = getTrips()
        for trip in trips {
                let tripAsDic = trip.saveAsDictionary()
                tripsDic.append(tripAsDic)
        }
        
        let dic: [String: AnyObject!] = [
            Keys.ID: id,
            Keys.NAME: name,
            Keys.TRIPS: tripsDic
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
    
    func loadTrips(dic: [String: AnyObject]) -> Bool {
        guard let id = dic[Keys.ID] as? String where id == self.id else {
            return false
        }
        
        if let tripDics = dic[Keys.TRIPS] as? [[String: AnyObject!]] {
            for tripDic in tripDics {
                let _ = Trip(dic: tripDic, traveller: self, context: self.managedObjectContext!)
            }
            return true
        } else {
            return false
        }
    }
}
