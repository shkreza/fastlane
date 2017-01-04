//
//  TripClient.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/20/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation
import CoreData
import Google
import UIKit

class TripClient {
    
    static var sharedInstance = TripClient()
    
    var traveller: Traveller!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return DataStackManager.sharedInstance.managedObjectContext
    }()
    
    lazy var session: URLSession = {
        return URLSession.shared
    }()
    
    func makeGetRequest(_ urlStr: String, headerParams: [String: String]?, params:[String: String]?, completionHandler: @escaping (_ error: NSError?, _ data: Data?)->Void)  -> URLSessionDataTask {
        var urlStr = urlStr
        urlStr = escapeCharacters(urlStr, params: params).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: urlStr)
        let request = NSMutableURLRequest(url: url!)
        if let headerParams = headerParams {
            let _ = headerParams.map({
                (key, val) in
                request.addValue(val, forHTTPHeaderField: key)
            })
        }
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            
            guard error == nil else {
                let userInfo = [NSLocalizedDescriptionKey: "Error conencting."]
                let error = NSError(domain: "makeGetRequest", code: 1, userInfo: userInfo)
                completionHandler(error, nil)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let userInfo = [NSLocalizedDescriptionKey: "Error status."]
                let error = NSError(domain: "makeGetRequest", code: 2, userInfo: userInfo)
                completionHandler(error, nil)
                return
            }
            
            guard let _ = data else {
                let userInfo = [NSLocalizedDescriptionKey: "Bad data."]
                let error = NSError(domain: "makeGetRequest", code: 3, userInfo: userInfo)
                completionHandler(error, nil)
                return
            }
            
            completionHandler(nil, data!)
        }) 
        task.resume()
        return task
    }
    
    func makePostRequest(_ urlStr: String, headerParams: [String: String]?, params:[String: String]?, body: Data?, completionHandler: @escaping (_ error: NSError?, _ data: Data?)->Void)  -> URLSessionDataTask {
        var urlStr = urlStr
        urlStr = escapeCharacters(urlStr, params: params).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: urlStr)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = body
        if let headerParams = headerParams {
            let _ = headerParams.map({
                (key, val) in
                request.addValue(val, forHTTPHeaderField: key)
            })
        }
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            
            guard error == nil else {
                let userInfo = [NSLocalizedDescriptionKey: "Error conencting."]
                let error = NSError(domain: "makePostRequest", code: 1, userInfo: userInfo)
                completionHandler(error, nil)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let strError = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                print(strError)
                let userInfo = [NSLocalizedDescriptionKey: "Bad status code (\((response as? HTTPURLResponse)?.statusCode))."]
                let error = NSError(domain: "makePostRequest", code: 2, userInfo: userInfo)
                completionHandler(error, nil)
                return
            }
            
            guard let _ = data else {
                let userInfo = [NSLocalizedDescriptionKey: "Bad data."]
                let error = NSError(domain: "makePostRequest", code: 3, userInfo: userInfo)
                completionHandler(error, nil)
                return
            }
            
            completionHandler(nil, data!)
        }) 
        task.resume()
        return task
    }
    
    func escapeCharacters(_ url: String, params: [String: String]?) -> String {
        if let params = params {
            var flattened = ""
            for (key, val) in params {
                flattened += "\(key)=\(val)&"
            }
            if url == "" {
                return flattened
            } else {
                return "\(url)?\(flattened)"
            }
        } else {
            return url
        }
    }
    
    func unloadTraveller() {
        if let traveller = traveller {
            sharedContext.delete(traveller)
            self.traveller = nil
        }
    }
    
    func loadFromCloud(_ view: UIViewController, tracker: ProgressTracker) {
        guard let _ = traveller else {
            showError(view, title: "Error", message: "No user is logged in.")
            return
        }
        
        tracker.progressStarted()
        let token = traveller.accessToken
        
        let headerParams: [String: String] = [
            TripClientConstants.GoogleRequestKeys.AUTHORIZATION:
            "Bearer \(token!)"
        ]
        _ = makeGetRequest(TripClientConstants.GoogleRequestValues.GOOGLE_DOWNLOAD_URL + "/\(traveller.id)",
            headerParams: headerParams, params: nil) {
                error, data in
                guard error == nil else {
                    let errorMessage = error?.description
                    DispatchQueue.main.async(execute: {
                        self.showError(view, title: "Save error", message: (errorMessage)!)
                        tracker.progressStopped()
                    })
                    return
                }
                
                guard let _ = data else {
                    DispatchQueue.main.async(execute: {
                        self.showError(view, title: "Save error - empty data", message: (error?.description)!)
                        tracker.progressStopped()
                    })
                    return
                }
                
                let response = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                print(response)
                DispatchQueue.main.async(execute: {
                    self.deleteTravellerTrips()
                    self.createNewTravellerTrips(response)
                    tracker.progressStopped()
                })
        }
    }
    
    func deleteTrip(_ trip: Trip!) {
        if let trip = trip {
            sharedContext.delete(trip)
        }
    }
    
    func deleteTravellerTrips() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Trip")
        let predicate = NSPredicate(format: "traveller.id == %@", traveller.id)
        fetchRequest.predicate = predicate
        let trips = try! sharedContext.fetch(fetchRequest) as! [Trip]
        for trip in trips {
            sharedContext.delete(trip)
        }
        
        saveContext()
    }
    
    func createNewTravellerTrips(_ travellerJson: [String: AnyObject?]) {
        if let traveller = traveller {
            traveller.loadTrips(travellerJson as [String : AnyObject])
        }
    }
    
    func saveTripsToCloud(_ view: UIViewController, tracker: ProgressTracker) {
        guard let _ = traveller else {
            showError(view, title: "Error", message: "No user is logged in.")
            return
        }
       
        tracker.progressStarted()
//        let str = "{\"kind\": \"storage#bucket\", \"id\": \"travellertrips\"}"
//        let data: NSData = str.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let data = traveller!.save()
        let token = traveller.accessToken
        
        let headerParams: [String: String] = [
            TripClientConstants.GoogleRequestKeys.CONTENT_TYPE: TripClientConstants.GoogleRequestValues.CONTENT_TYPE_JSON,
            TripClientConstants.GoogleRequestKeys.CONTENT_LENGTH:
            "\(data.count)",
            TripClientConstants.GoogleRequestKeys.AUTHORIZATION:
            "Bearer \(token!)"
        ]
        let params: [String: String] = [
            TripClientConstants.GoogleRequestKeys.GOOGLE_PROJECT:
                TripClientConstants.GoogleRequestValues.GOOGLE_PROJECT_ID,
            TripClientConstants.GoogleRequestKeys.UPLOAD_TYPE: TripClientConstants.GoogleRequestValues.UPLOAD_TYPE_MEDIA,
            TripClientConstants.GoogleRequestKeys.UPLOAD_NAME: "\(traveller.id)"
        ]
        makePostRequest(TripClientConstants.GoogleRequestValues.GOOGLE_UPLOAD_URL,
            headerParams: headerParams, params: params, body: data as Data) {
            error, data in
                guard error == nil else {
                    let errorMessage = error?.description
                    DispatchQueue.main.async(execute: {
                        self.showError(view, title: "Save error", message: (errorMessage)!)
                        tracker.progressStopped()
                        })
                    return
                }
                
                guard let _ = data else {
                    DispatchQueue.main.async(execute: {
                        self.showError(view, title: "Save error - empty data", message: (error?.description)!)
                        tracker.progressStopped()
                        })
                    return
                }
                
                let response = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                print(response)
                DispatchQueue.main.async(execute: {
                    tracker.progressStopped()
                })
        }
    }
    
    func loadTraveller(_ user: GIDGoogleUser) {
        let id = user.userID!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Traveller")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try! sharedContext.fetch(fetchRequest)
        if results.count == 1 {
            traveller = results[0] as! Traveller
        } else if results.count == 0 {
            traveller = Traveller(user: user, context: sharedContext)
            saveContext()
        } else {
            print("Many travellers with same id exist: \(results)")
            abort()
        }
    }
    
    func saveContext() {
        DataStackManager.sharedInstance.saveContext()
    }
}
