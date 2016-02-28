//
//  LoginViewController.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/27/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation
import UIKit
import Google

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    lazy var tripClient: TripClient = {
        return TripClient.sharedInstance
    }()
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        tripClient = TripClient.sharedInstance
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
    }
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        return
    }
}