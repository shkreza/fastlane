//
//  ActivityIndicator.swift
//  fastlane
//
//  Created by Reza Sherafat on 3/7/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation
import UIKit

class ActivityIndicator: UIActivityIndicatorView, ProgressTracker {
    func progressStarted() {
        print("Progress underway")
        self.startAnimating()
    }
    
    func progressStopped() {
        print("Progress has stopped")
        self.stopAnimating()
    }
}