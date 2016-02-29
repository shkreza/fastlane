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
    
    @NSManaged var id: String
    @NSManaged var name: String!
    @NSManaged var token: String!
    @NSManaged var accessToken: String!
    
    @NSManaged var trips: [Trip]!
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(user: GIDGoogleUser, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Traveller", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        id = user.userID
        name = user.profile.name
        token = user.authentication.idToken!
        accessToken = user.authentication.accessToken
    }
}