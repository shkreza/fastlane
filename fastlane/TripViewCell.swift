//
//  TripViewController.swift
//  fastlane
//
//  Created by Reza Sherafat on 3/2/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation

class TripViewCell: UITableViewCell {
    
    @IBOutlet weak var tripLabel: UILabel!
    var tripClient: TripClient!
    var trip: Trip!
    
    @IBAction func deleteTrip(sender: AnyObject) {
        tripClient.deleteTrip(trip)
        tripClient.saveContext()
    }
}