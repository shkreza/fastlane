//
//  TripClientConstants.swift
//  fastlane
//
//  Created by Reza Sherafat on 2/22/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation

struct TripClientConstants {
    
    struct GoogleRequestKeys {
        static let VERIFICATION_URL = "https://www.googleapis.com/oauth2/v3/tokeninfo"
        static let ID_TOKEN = "id_token"
        static let HEADER_ACCEPT = "application/json"
    }
    
    struct GoogleResponseKeys {
        static let SUB = "sub"
        static let AUD = "aud"
        static let ISS = "iss"
    }
    
    struct GoogleResponseValues {
        static let ISS_VAL = "https://accounts.google.com"
    }
}