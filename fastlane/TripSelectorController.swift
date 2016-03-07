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
    
    func prepLogoutButton() {
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButtonPRessed:")
        navigationItem.leftBarButtonItem = logoutButton
    }
    
    @IBAction func logoutButtonPRessed(sender: AnyObject) {
        logUserOut()
        navigationController?.popViewControllerAnimated(true)
//        navigationController?.dismissViewControllerAnimated(true, completion: {
//            self.tripClient.unloadTraveller()
//        })
    }
    
    func logUserOut() {
        tripClient.unloadTraveller()
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
        prepBackButton()
        
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
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        let dateString = formatter.stringFromDate(date)
        let trip = Trip(title: "Trip on \(dateString)", traveller: traveller, context: sharedContext)
        if let traveller = traveller {
            trip.traveller = traveller
        }
        return trip
    }
    
    func prepBackButton() {
        let logoutButton = UIBarButtonItem()
        logoutButton.title = "Back"
        navigationItem.backBarButtonItem = logoutButton
    }
}

extension TripSelectorController: UITableViewDataSource {
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
        let tripCell = (tripsTable.dequeueReusableCellWithIdentifier("TripCellID")) as! TripViewCell
        tripCell.tripClient = tripClient
        tripCell.trip = trip
        tripCell.textLabel?.text = trip.title
        return tripCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == tripsTable {
            let trip = fetchTripsResultController.objectAtIndexPath(indexPath) as! Trip
            let tripMap = storyboard?.instantiateViewControllerWithIdentifier("TripMapController") as! TripMapController
            tripMap.tripClient = tripClient
            tripMap.trip = trip
            navigationController?.pushViewController(tripMap, animated: true)
        }
    }
}

extension TripSelectorController: UITableViewDelegate {
    func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        return
    }
    
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        return
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TripViewCell
        let cellTrip = cell.trip
        switch editingStyle {
        case .Delete:
            print("Deleting \(cellTrip.title)")
            sharedContext.deleteObject(cellTrip)
            try! sharedContext.save()
            
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Delete trip"
    }
}

extension TripSelectorController: NSFetchedResultsControllerDelegate {
    
    func updateCell(trip: Trip, cell: TripViewCell) {
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
            let cell = tripsTable.cellForRowAtIndexPath(indexPath!) as! TripViewCell
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