//
//  ViewController.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/19/16.
//  Copyright © 2016 No org. All rights reserved.
//

import UIKit

class TripMapController: UIViewController {
    
    lazy var tripClient: TripClient = {
        return TripClient.sharedInstance
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

}

