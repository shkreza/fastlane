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
    
    lazy var session: NSURLSession = {
        return NSURLSession.sharedSession()
    }()
    
    func makeGetRequest(var urlStr: String, headerParams: [String: String]?, params:[String: String]?, completionHandler: (error: NSError?, data: NSData?)->Void)  -> NSURLSessionDataTask {
        urlStr = escapeCharacters(urlStr, params: params).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: urlStr)
        let request = NSMutableURLRequest(URL: url!)
        if let headerParams = headerParams {
            let _ = headerParams.map({
                (key, val) in
                request.addValue(val, forHTTPHeaderField: key)
            })
        }
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            guard error == nil else {
                let userInfo = [NSLocalizedDescriptionKey: "Error conencting."]
                let error = NSError(domain: "makeGetRequest", code: 1, userInfo: userInfo)
                completionHandler(error: error, data: nil)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                let userInfo = [NSLocalizedDescriptionKey: "Error status."]
                let error = NSError(domain: "makeGetRequest", code: 2, userInfo: userInfo)
                completionHandler(error: error, data: nil)
                return
            }
            
            guard let _ = data else {
                let userInfo = [NSLocalizedDescriptionKey: "Bad data."]
                let error = NSError(domain: "makeGetRequest", code: 3, userInfo: userInfo)
                completionHandler(error: error, data: nil)
                return
            }
            
            completionHandler(error: nil, data: data!)
        }
        task.resume()
        return task
    }
    
    func makePostRequest(var urlStr: String, headerParams: [String: String]?, params:[String: String]?, body: NSData?, completionHandler: (error: NSError?, data: NSData?)->Void)  -> NSURLSessionDataTask {
        urlStr = escapeCharacters(urlStr, params: params).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: urlStr)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = body
        if let headerParams = headerParams {
            let _ = headerParams.map({
                (key, val) in
                request.addValue(val, forHTTPHeaderField: key)
            })
        }
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            guard error == nil else {
                let userInfo = [NSLocalizedDescriptionKey: "Error conencting."]
                let error = NSError(domain: "makePostRequest", code: 1, userInfo: userInfo)
                completionHandler(error: error, data: nil)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                let strError = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String: AnyObject]
                print(strError)
                let userInfo = [NSLocalizedDescriptionKey: "Bad status code (\((response as? NSHTTPURLResponse)?.statusCode))."]
                let error = NSError(domain: "makePostRequest", code: 2, userInfo: userInfo)
                completionHandler(error: error, data: nil)
                return
            }
            
            guard let _ = data else {
                let userInfo = [NSLocalizedDescriptionKey: "Bad data."]
                let error = NSError(domain: "makePostRequest", code: 3, userInfo: userInfo)
                completionHandler(error: error, data: nil)
                return
            }
            
            completionHandler(error: nil, data: data!)
        }
        task.resume()
        return task
    }
    
    func escapeCharacters(url: String, params: [String: String]?) -> String {
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
            sharedContext.deleteObject(traveller)
            self.traveller = nil
        }
    }
    
    func loadFromCloud(view: UIViewController) {
        guard let _ = traveller else {
            showError(view, title: "Error", message: "No user is logged in.")
            return
        }
        
        let token = traveller.accessToken
        
        let headerParams: [String: String] = [
            TripClientConstants.GoogleRequestKeys.AUTHORIZATION:
            "Bearer \(token)"
        ]
        makeGetRequest(TripClientConstants.GoogleRequestValues.GOOGLE_DOWNLOAD_URL + "/\(traveller.id)",
            headerParams: headerParams, params: nil) {
                error, data in
                guard error == nil else {
                    let errorMessage = error?.description
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showError(view, title: "Save error", message: (errorMessage)!)
                    })
                    return
                }
                
                guard let _ = data else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showError(view, title: "Save error - empty data", message: (error?.description)!)
                    })
                    return
                }
                
                let response = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String: AnyObject]
                print(response)
        }
    }
    
    func saveTripsToCloud(view: UIViewController) {
        guard let _ = traveller else {
            showError(view, title: "Error", message: "No user is logged in.")
            return
        }
       
        let str = "{\"kind\": \"storage#bucket\", \"id\": \"travellertrips\"}"

        let data: NSData = str.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let token = traveller.accessToken
        
        let headerParams: [String: String] = [
            TripClientConstants.GoogleRequestKeys.CONTENT_TYPE: TripClientConstants.GoogleRequestValues.CONTENT_TYPE_JSON,
            TripClientConstants.GoogleRequestKeys.CONTENT_LENGTH:
            "\(data.length)",
            TripClientConstants.GoogleRequestKeys.AUTHORIZATION:
            "Bearer \(token)"
        ]
        let params: [String: String] = [
            TripClientConstants.GoogleRequestKeys.GOOGLE_PROJECT:
                TripClientConstants.GoogleRequestValues.GOOGLE_PROJECT_ID,
            TripClientConstants.GoogleRequestKeys.UPLOAD_TYPE: TripClientConstants.GoogleRequestValues.UPLOAD_TYPE_MEDIA,
            TripClientConstants.GoogleRequestKeys.UPLOAD_NAME: "\(traveller.id)"
        ]
        makePostRequest(TripClientConstants.GoogleRequestValues.GOOGLE_UPLOAD_URL,
            headerParams: headerParams, params: params, body: data) {
            error, data in
                guard error == nil else {
                    let errorMessage = error?.description
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showError(view, title: "Save error", message: (errorMessage)!)
                        })
                    return
                }
                
                guard let _ = data else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showError(view, title: "Save error - empty data", message: (error?.description)!)
                        })
                    return
                }
                
                let response = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String: AnyObject]
                print(response)
        }
    }
    
    func loadTraveller(user: GIDGoogleUser) {
        let id = user.userID!
        let fetchRequest = NSFetchRequest(entityName: "Traveller")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let results = try! sharedContext.executeFetchRequest(fetchRequest)
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