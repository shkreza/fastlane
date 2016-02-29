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
        static let ID_TOKEN = "id_token"
        static let CONTENT_LENGTH = "Content-Length"
        static let CONTENT_TYPE = "Content-Type"
        static let AUTHORIZATION = "Authorization"
        static let HEADER_ACCEPT = "Accept"
        static let UPLOAD_TYPE = "uploadType"
        static let UPLOAD_NAME = "name"
        static let GOOGLE_PROJECT = "project"
    }
    
    struct GoogleRequestValues {
        static let VERIFICATION_URL = "https://www.googleapis.com/oauth2/v3/tokeninfo"
        static let GOOGLE_UPLOAD_URL = "https://www.googleapis.com/upload/storage/v1/b/\(GOOGLE_BUCKET_NAME)/o/"
        static let GOOGLE_DOWNLOAD_URL = "https://\(GOOGLE_BUCKET_NAME).storage.googleapis.com"
        static let HEADER_ACCEPT = "application/json"
        static let UPLOAD_TYPE_MEDIA = "media"
        static let CONTENT_TYPE_JSON = "Application/json"
        static let GOOGLE_PROJECT_ID = "870002604490"
        static let GOOGLE_BUCKET_NAME = "travellertrips"
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