//
//  TripClientController.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/27/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation
import UIKit

extension TripClient {
    func showError(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: title, style: .Default, handler: nil)
        alert.addAction(action)
    }
}