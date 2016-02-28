//
//  Trip.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/20/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation
import CoreData

class Trip: NSManagedObject {
    
    @NSManaged var title: String!
    @NSManaged var traveller: Traveller!
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(title: String, traveller: Traveller!, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        self.title = title
        self.traveller = traveller
    }
}