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
    @IBOutlet weak var activityTracker: ActivityIndicator!
    
    override func viewDidLoad() {
        tripClient = TripClient.sharedInstance
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/devstorage.read_write")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityTracker.stopAnimating()
    }
    
    @IBAction func anonymousLoginButtonPressed(sender: AnyObject) {
        handlePostLogin(nil)
    }
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        activityTracker.startAnimating()
        return
    }
}