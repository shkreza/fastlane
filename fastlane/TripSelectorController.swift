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
    @IBOutlet weak var activityIndicator: ActivityIndicator!
    
    var fetchTripsResultController: NSFetchedResultsController<NSFetchRequestResult>!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return DataStackManager.sharedInstance.managedObjectContext
    }()
    
    lazy var tripClient: TripClient = {
        return TripClient.sharedInstance
    }()
    
    func initFetchTripsResultsController() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Trip")
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
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TripSelectorController.logoutButtonPRessed(_:)))
        navigationItem.leftBarButtonItem = logoutButton
    }
    
    @IBAction func logoutButtonPRessed(_ sender: AnyObject) {
        logUserOut()
        navigationController?.popViewController(animated: true)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = tripClient.traveller {
            saveToCloudButton.isEnabled = true
            loadFromCloudButton.isEnabled = true
        } else {
            saveToCloudButton.isEnabled = false
            loadFromCloudButton.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        prepLogoutButton()
        prepBackButton()
        
        tripsTable.delegate = self
        tripsTable.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func loadFromCloud(_ sender: AnyObject) {
        tripClient.loadFromCloud(self, tracker: activityIndicator)
    }

    @IBAction func saveToCloud(_ sender: AnyObject) {
        tripClient.saveTripsToCloud(self, tracker: activityIndicator)
    }
    
    @IBAction func newTripPressed(_ sender: AnyObject) {
        let traveller = tripClient.traveller
        createNewTrip(traveller)
        saveTrips()
    }
    
    func createNewTrip(_ traveller: Traveller!) -> Trip {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let dateString = formatter.string(from: date)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetchTripsResultController = fetchTripsResultController {
            let sectionInfo = fetchTripsResultController.sections?[section]
            let cellCount = (sectionInfo?.numberOfObjects)!
            return cellCount
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionInfos = fetchTripsResultController.sections
        let sectionInfo = sectionInfos?[indexPath.section]
        let trip = sectionInfo?.objects?[indexPath.row] as! Trip
        let tripCell = (tripsTable.dequeueReusableCell(withIdentifier: "TripCellID")) as! TripViewCell
        tripCell.tripClient = tripClient
        tripCell.trip = trip
        tripCell.textLabel?.text = trip.title
        return tripCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tripsTable {
            let trip = fetchTripsResultController.object(at: indexPath) as! Trip
            let tripMap = storyboard?.instantiateViewController(withIdentifier: "TripMapController") as! TripMapController
            tripMap.tripClient = tripClient
            tripMap.trip = trip
            navigationController?.pushViewController(tripMap, animated: true)
        }
    }
}

extension TripSelectorController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        return
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        return
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TripViewCell
        let cellTrip = cell.trip
        switch editingStyle {
        case .delete:
            print("Deleting \(cellTrip?.title)")
            sharedContext.delete(cellTrip!)
            try! sharedContext.save()
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete trip"
    }
}

extension TripSelectorController: NSFetchedResultsControllerDelegate {
    
    func updateCell(_ trip: Trip, cell: TripViewCell) {
        cell.textLabel?.text = trip.title
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tripsTable.deleteRows(at: [indexPath!], with: .right)
            
        case .insert:
            tripsTable.insertRows(at: [newIndexPath!], with: .left)

        case .move:
            tripsTable.deleteRows(at: [indexPath!], with: .right)
            tripsTable.insertRows(at: [newIndexPath!], with: .left)
            
        case .update:
            let trip = anObject as! Trip
            let cell = tripsTable.cellForRow(at: indexPath!) as! TripViewCell
            updateCell(trip, cell: cell)
        }
        
        return
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        return
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tripsTable.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tripsTable.endUpdates()
    }
}
