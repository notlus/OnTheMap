//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/25/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import UIKit

class StudentLocationClient: NSObject {
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
    }
    
    func getStudentLocations() -> [StudentLocation] {
        return []
    }
    
    func postStudentLocation(studentLocation: StudentLocation) -> Bool {
        return false
    }
    
    func queryStudentLocation(queryString: String) -> [StudentLocation] {
        return []
    }
    
    func updateStudentLocation(studentLocation: StudentLocation) -> Bool {
        return false
    }
   
}

extension StudentLocationClient {
    
    struct Constants {
        let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        let BaseURL = "https://api.parse.com/1/classes/StudentLocation"
        let AppIDHeader = "X-Parse-Application-Id"
        let APIKeyHeader = "X-Parse-REST-API-Key"
    }
    
    struct RequestKeys {
        let limit = "limit"
    }
    
}