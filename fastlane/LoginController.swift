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
    
    @objc func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
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
            
            self.handlePostLogin(user!)
        }
    }
    
    @objc func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
        withError error: NSError!) {
            // Perform any operations when the user disconnects from app here.
    }
    
    func verifyUserToken(user: GIDGoogleUser?, completionHandler: (user: GIDGoogleUser?, error: NSError?)->Void) {
        guard let _ = user else {
            let userInfo = [NSLocalizedDescriptionKey: "Invalid user."]
            let error = NSError(domain: "VerifyUserToken", code: 1, userInfo: userInfo)
            completionHandler(user: nil, error: error)
            return
        }

        guard let _ = user!.authentication.idToken else {
            let userInfo = [NSLocalizedDescriptionKey: "Invalid user id token."]
            let error = NSError(domain: "VerifyUserToken", code: 2, userInfo: userInfo)
            completionHandler(user: nil, error: error)
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
                completionHandler(user: nil, error: error)
                return
            }
            
            do {
                let resposne = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String: AnyObject!]
                guard let sub = resposne[TripClientConstants.GoogleResponseKeys.SUB] as? String where sub == user!.userID else {
                    let userInfo = [NSLocalizedDescriptionKey: "Invalid user id validation: \(user!.userID) vs \(resposne[TripClientConstants.GoogleResponseKeys.SUB])."]
                    let error = NSError(domain: "VerifyUserToken", code: 3, userInfo: userInfo)
                    completionHandler(user: nil, error: error)
                    return
                }
                
                completionHandler(user: user, error: nil)
                return
            } catch let jsonError {
                let userInfo = [NSLocalizedDescriptionKey: "Invalid json response: \(jsonError)."]
                let error = NSError(domain: "VerifyUserToken", code: 4, userInfo: userInfo)
                completionHandler(user: nil, error: error)
                return
            }
        }
    }
    
    func handlePostLogin(user: GIDGoogleUser!) {
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
        let tripSelectorController = storyboard?.instantiateViewControllerWithIdentifier("TripSelectorController") as! TripSelectorController
        tripSelectorController.initFetchTripsResultsController()
        navigationController?.presentViewController(tripSelectorController, animated: true, completion: nil)
    }
}