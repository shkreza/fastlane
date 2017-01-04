//
//  LoginController.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/27/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation
import Google

extension LoginViewController: GIDSignInDelegate {
    
    @objc public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            let message = "Sign in failed: \(error)"
            tripClient.showError(self, title: "Error", message: message)
            return
        }
        
        verifyUserToken(user) {
            user, error in
            guard error == nil else {
                let message = "Sign in failed: \(error)"
                self.tripClient.showError(self, title: "Error", message: message)
                return
            }
            
            guard let _ = user else {
                let message = "Sign in failed."
                self.tripClient.showError(self, title: "Error", message: message)
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.handlePostLogin(user!)
            })
        }
    }
    
    @objc func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }
    
    func verifyUserToken(_ user: GIDGoogleUser?, completionHandler: @escaping (_ user: GIDGoogleUser?, _ error: NSError?)->Void) {
        guard let _ = user else {
            let userInfo = [NSLocalizedDescriptionKey: "Invalid user."]
            let error = NSError(domain: "VerifyUserToken", code: 1, userInfo: userInfo)
            completionHandler(nil, error)
            return
        }

        guard let _ = user!.authentication.idToken else {
            let userInfo = [NSLocalizedDescriptionKey: "Invalid user id token."]
            let error = NSError(domain: "VerifyUserToken", code: 2, userInfo: userInfo)
            completionHandler(nil, error)
            return
        }
        
        let headerParams = [
            TripClientConstants.GoogleRequestKeys.HEADER_ACCEPT:
                TripClientConstants.GoogleRequestValues.HEADER_ACCEPT
        ]
        let params = [
            TripClientConstants.GoogleRequestKeys.ID_TOKEN:
                user!.authentication.idToken!
        ]
        tripClient.makePostRequest(TripClientConstants.GoogleRequestValues.VERIFICATION_URL, headerParams: headerParams, params: params, body: nil) {
            (error, data) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            do {
                let resposne = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject?]
                guard let sub = resposne[TripClientConstants.GoogleResponseKeys.SUB] as? String, sub == user!.userID else {
                    let userInfo = [NSLocalizedDescriptionKey: "Invalid user id validation: \(user!.userID) vs \(resposne[TripClientConstants.GoogleResponseKeys.SUB])."]
                    let error = NSError(domain: "VerifyUserToken", code: 3, userInfo: userInfo)
                    completionHandler(nil, error)
                    return
                }
                
                completionHandler(user, nil)
                return
            } catch let jsonError {
                let userInfo = [NSLocalizedDescriptionKey: "Invalid json response: \(jsonError)."]
                let error = NSError(domain: "VerifyUserToken", code: 4, userInfo: userInfo)
                completionHandler(nil, error)
                return
            }
        }
    }
    
    func handlePostLogin(_ user: GIDGoogleUser!) {
        if let user = user {
            print("User \(user.profile.name) has logged in: \(user.userID)")
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let name = user.profile.name
            let email = user.profile.email
            print("id: \(userId)")
            print("token: \(idToken)")
            print("name: \(name)")
            print("email: \(email)")
            
            tripClient.loadTraveller(user)
        }

        presentPostLoginView()
    }
    
    func presentPostLoginView() {
        let tripSelectorController = storyboard?.instantiateViewController(withIdentifier: "TripSelectorController") as! TripSelectorController
        tripSelectorController.initFetchTripsResultsController()
        navigationController!.pushViewController(tripSelectorController, animated: true)
    }
}
