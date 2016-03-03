//
//  ViewController.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/19/16.
//  Copyright © 2016 No org. All rights reserved.
//

import CoreData
import MapKit
import UIKit

class TripMapController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lane1: UIButton!
    @IBOutlet weak var lane2: UIButton!
    @IBOutlet weak var lane3: UIButton!
    @IBOutlet weak var lane4: UIButton!
    @IBOutlet weak var lane5: UIButton!
    
    var trip: Trip!
    
    lazy var tripClient: TripClient = {
        return TripClient.sharedInstance
    }()

    lazy var sharedContext: NSManagedObjectContext = {
        return self.tripClient.sharedContext
    }()
    
    lazy var dummyTrip: Trip = {
        return Trip(title: "Dummy", traveller: nil, context: self.sharedContext)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func laneSelected(sender: UIButton) {
        switch sender {
        case lane1:
            recordLane(1)
            
        case lane2:
            recordLane(2)
            
        case lane3:
            recordLane(3)
            
        case lane4:
            recordLane(4)
            
        case lane5:
            recordLane(5)
            
        default:
            return
        }
    }
    
    func recordLane(lane: Int) {
        print(lane)
        let coord = map.centerCoordinate
        if let trip = trip {
            let lane = Lane(coord: coord, lane: lane, trip: trip, context: sharedContext)
            let annotation = createAnnotation(lane)
            map.addAnnotation(annotation)
        } else {
            let lane = Lane(coord: coord, lane: lane, trip: dummyTrip, context: sharedContext)
            let annotation = createAnnotation(lane)
            map.addAnnotation(annotation)
        }
    }
    
    func createAnnotation(lane: Lane) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "\(lane.trip.title): \(lane.lane)"
        annotation.coordinate = lane.coord
        return annotation
    }
}