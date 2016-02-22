//
//  TripSelectorController.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/20/16.
//  Copyright © 2016 No org. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class TripSelectorController: UIViewController {
    
    @IBOutlet weak var tripsTable: UITableView!
    
    lazy var fetchTripsResultController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResultsController
    }()
    
    lazy var sharedContext: NSManagedObjectContext = {
        return DataStackManager.sharedInstance.managedObjectContext
    }()
    
    func saveTrips() {
        DataStackManager.sharedInstance.saveContext()
    }
    
    override func viewDidLoad() {
        tripsTable.delegate = self
        tripsTable.dataSource = self
        fetchTripsResultController.delegate = self
        try! fetchTripsResultController.performFetch()
    }

    @IBAction func newTripPressed(sender: UIBarButtonItem) {
        createNewTrip()
        saveTrips()
    }
    
    func createNewTrip() -> Trip {
        let date = NSDate()
        let trip = Trip(title: "\(date)", context: sharedContext)
        
        return trip
    }
}

extension TripSelectorController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchTripsResultController.sections?[section]
        let cellCount = (sectionInfo?.numberOfObjects)!
        return cellCount
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