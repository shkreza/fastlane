//
//  ProgressTracker.swift
//  fastlane
//
//  Created by Reza Sherafat on 3/7/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation

protocol ProgressTracker {
    func progressStarted()
    func progressStopped()
}