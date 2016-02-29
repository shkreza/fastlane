//
//  TripSelectorController.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/20/16.
//  Copyright © 2016 No org. All rights reserved.
//

import CoreData
import Foundation
import Google
import UIKit

class TripSelectorController: UIViewController {
    
    @IBOutlet weak var tripsTable: UITableView!
    
    var fetchTripsResultController: NSFetchedResultsController!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return DataStackManager.sharedInstance.managedObjectContext
    }()
    
    lazy var tripClient: TripClient = {
        return TripClient.sharedInstance
    }()
    
    func initFetchTripsResultsController() {
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let traveller = self.tripClient.traveller {
            let predicate = NSPredicate(format: "traveller.id == %@", traveller.id)
            fetchRequest.predicate = predicate
        } else {
            let predicate = NSPredicate(format: "traveller.id == nil", argumentArray: nil)
            fetchRequest.predicate = predicate
        }
        fetchTripsResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchTripsResultController.delegate = self
        try! fetchTripsResultController.performFetch()
    }
    
    func saveTrips() {
        DataStackManager.sharedInstance.saveContext()
    }
    
    @IBAction func logoutButtonPRessed(sender: AnyObject) {
        logUserOut()
        self.dismissViewControllerAnimated(true, completion: {
            self.tripClient.unloadTraveller()
        })
    }
    
    func logUserOut() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    @IBOutlet weak var loadFromCloudButton: UIBarButtonItem!
    @IBOutlet weak var saveToCloudButton: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = tripClient.traveller {
            saveToCloudButton.enabled = true
            loadFromCloudButton.enabled = true
        } else {
            saveToCloudButton.enabled = false
            loadFromCloudButton.enabled = false
        }
    }
    
    override func viewDidLoad() {
        prepLogoutButton()
        
        tripsTable.delegate = self
        tripsTable.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func loadFromCloud(sender: AnyObject) {
        tripClient.loadFromCloud(self)
    }

    @IBAction func saveToCloud(sender: AnyObject) {
        tripClient.saveTripsToCloud(self)
    }
    
    @IBAction func newTripPressed(sender: AnyObject) {
        let traveller = tripClient.traveller
        createNewTrip(traveller)
        saveTrips()
    }
    
    func createNewTrip(traveller: Traveller!) -> Trip {
        let date = NSDate()
        let trip = Trip(title: "\(date)", traveller: traveller, context: sharedContext)
        
        return trip
    }
    
    func prepLogoutButton() {
        let logoutButton = UIBarButtonItem()
        logoutButton.title = "Logout"
        navigationItem.backBarButtonItem = logoutButton
    }
}

extension TripSelectorController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetchTripsResultController = fetchTripsResultController {
            let sectionInfo = fetchTripsResultController.sections?[section]
            let cellCount = (sectionInfo?.numberOfObjects)!
            return cellCount
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sectionInfos = fetchTripsResultController.sections
        let sectionInfo = sectionInfos?[indexPath.section]
        let trip = sectionInfo?.objects?[indexPath.row] as! Trip
        let cell = (tripsTable.dequeueReusableCellWithIdentifier("TripCellID")) as! TripCell
        cell.textLabel?.text = trip.title
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == tripsTable {
            let trip = fetchTripsResultController.objectAtIndexPath(indexPath) as! Trip
            sharedContext.deleteObject(trip)
            saveTrips()
        }
    }
}

extension TripSelectorController: NSFetchedResultsControllerDelegate {
    
    func updateCell(trip: Trip, cell: TripCell) {
        cell.textLabel?.text = trip.title
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete:
            tripsTable.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Right)
            
        case .Insert:
            tripsTable.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Left)

        case .Move:
            tripsTable.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Right)
            tripsTable.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Left)
            
        case .Update:
            let trip = anObject as! Trip
            let cell = tripsTable.cellForRowAtIndexPath(indexPath!) as! TripCell
            updateCell(trip, cell: cell)
        }
        
        return
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        return
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tripsTable.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tripsTable.endUpdates()
    }
}