//
//  TripClient.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/20/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation
import UIKit

class TripClient {
    
    lazy var session: NSURLSession = {
        return NSURLSession.sharedSession()
    }()
    
    func makeGetRequest(var urlStr: String, headerParams: [String: String]?, params:[String: String]?, completionHandler: (error: NSError?, data: NSData?)->Void)  -> NSURLSessionDataTask {
        urlStr = escapeCharacters(urlStr, params: params)
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
        urlStr = escapeCharacters(urlStr, params: params)
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
                let userInfo = [NSLocalizedDescriptionKey: "Error status."]
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
}