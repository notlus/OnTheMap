//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/25/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import Foundation

/// Represents the location information for a student
struct StudentInformation {
    var createdAt: String?
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    var objectID: String?
    var uniqueKey: String?
    var updatedAt: String?
    
    init(studentInfo: [String: AnyObject]) {
        self.createdAt = studentInfo["createdAt"] as? String
        self.firstName = studentInfo["firstName"] as! String
        self.lastName = studentInfo["lastName"] as! String
        self.latitude = studentInfo["latitude"] as! Double
        self.longitude = studentInfo["longitude"] as! Double
        self.mapString = studentInfo["mapString"] as! String
        self.mediaURL = studentInfo["mediaURL"] as! String
        self.objectID = studentInfo["objectId"] as? String
        self.uniqueKey = studentInfo["uniqueKey"] as? String
        self.updatedAt = studentInfo["updatedAt"] as? String
    }
}