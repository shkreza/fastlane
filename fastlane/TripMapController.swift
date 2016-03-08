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

class TripMapController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var laneSegments: UISegmentedControl!
    @IBOutlet weak var map: MKMapView!
    
    var trip: Trip!
    var locManager = CLLocationManager()

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
        
        map.delegate = self
        initLocationManager()
    }
    
    @IBAction func laneSelected(sender: AnyObject, forEvent event: UIEvent) {
        if laneSegments == sender as? NSObject {
            let index = laneSegments.selectedSegmentIndex
            
            recordLane(index + 1)
            laneSegments.selectedSegmentIndex = -1
        }
    }
    
    func laneSelected(event: UIControlEvents) {
        print(event)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    var currentLocation: CLLocation!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        laneSegments.selectedSegmentIndex = -1
        
//        locManager.requestLocation()
        locManager.startUpdatingLocation()
        currentLocation = locManager.location
        map.showsUserLocation = true
        map.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        map.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(), 2000, 2000)
        addExistingPins()
    }
    
    @IBAction func handleLongTap(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .Ended:
            let loc = sender.locationInView(map)
            let coord = map.convertPoint(loc, toCoordinateFromView: map)
            laneCounter = laneCounter + 1
            let lane = Lane(coord: coord, lane: laneCounter, trip: trip, context: sharedContext)
            addPin(lane, primaryTrip: true)
            
        default:
            break
        }
    }
    
    var laneCounter: Int = 0
    
    func addPin(lane: Lane, primaryTrip: Bool) {
        if let _ = trip {
            let laneAnnotation = LaneAnnotation(lane: lane, primaryTrip: primaryTrip)
            map.addAnnotation(laneAnnotation)
        } else {
            let laneAnnotation = LaneAnnotation(lane: lane, primaryTrip: primaryTrip)
            map.addAnnotation(laneAnnotation)
        }
    }
    
    func addExistingPins() {
        let currentTripLanesFetchRequest = NSFetchRequest(entityName: "Lane")
        if let trip = trip {
            let tripId = trip.title
            currentTripLanesFetchRequest.predicate = NSPredicate(format: "trip.title == %@", tripId)
        }
        let currentTripLanes = try! sharedContext.executeFetchRequest(currentTripLanesFetchRequest) as! [Lane]
        for lane in currentTripLanes {
            addPin(lane, primaryTrip: true)
        }
        
        if let trip = trip {
            let tripId = trip.title
            let nonCrrentTripLanesFetchRequest = NSFetchRequest(entityName: "Lane")
            nonCrrentTripLanesFetchRequest.predicate = NSPredicate(format: "trip.title <> %@", tripId)
            let nonCurrentTripLanes = try! sharedContext.executeFetchRequest(nonCrrentTripLanesFetchRequest) as! [Lane]
            for lane in nonCurrentTripLanes {
                addPin(lane, primaryTrip: false)
            }
        }
    }
    
    func initDirections(sourceLocation: CLLocation!) {
        guard let _ = sourceLocation else {
            return
        }
        
        let coord = sourceLocation?.coordinate
        map.region.center = sourceLocation.coordinate
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: coord!, addressDictionary: nil))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.783333, longitude: -122.416667), addressDictionary: nil))

        let request = MKDirectionsRequest()
        request.source = source
        request.destination = destination
        request.requestsAlternateRoutes = false
        request.transportType = .Automobile

        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler() {
            response, error in
            guard error == nil else { return }
            guard let _ = response else { return }
            let route = response?.routes[0]
            self.map.addOverlay((route?.polyline)!)
//            self.map.setVisibleMapRect((route?.polyline.boundingMapRect)!, animated: true)
        }
    }
    
    func initLocationManager() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .NotDetermined:
            locManager.requestAlwaysAuthorization()
            print("\(CLLocationManager.authorizationStatus().rawValue) vs. \(authorizationStatus.rawValue)")
            
        default:
            break
        }

        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        } else {
            print("Location service is not enabled")
            abort()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let endIndex = locations.endIndex
        let currentLocation = locations[endIndex - 1]
        map.region.center = currentLocation.coordinate
        print("Current location: \(currentLocation)")
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blueColor()
        return renderer
    }

    func recordLane(lane: Int) {
        print(lane)
        let coord = map.centerCoordinate
        if let trip = trip {
            let lane = Lane(coord: coord, lane: lane, trip: trip, context: sharedContext)
            let annotation = createAnnotation(lane, primaryTrip: true)
            map.addAnnotation(annotation)
        } else {
            let lane = Lane(coord: coord, lane: lane, trip: dummyTrip, context: sharedContext)
            let annotation = createAnnotation(lane, primaryTrip: true)
            map.addAnnotation(annotation)
        }
    }
    
    func createAnnotation(lane: Lane, primaryTrip: Bool) -> MKAnnotation {
        let annotation = LaneAnnotation(lane: lane, primaryTrip: primaryTrip)
        return annotation
    }
}


extension TripMapController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is LaneAnnotation {
            let laneAnnotation = annotation as! LaneAnnotation
            let annotationView = LaneAnnotationView(annotation: laneAnnotation, reuseIdentifier: "LaneAnnotationView")
            annotationView.canShowCallout = false
            return annotationView
        } else {
            return nil
        }
    }
}