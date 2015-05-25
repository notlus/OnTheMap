//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/25/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import Foundation

struct StudentLocation {
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Float
    var longitude: Float
    
    init(firstName: String, lastName:String, mapString: String, mediaURL: String, latitude: Float, longitude: Float) {
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
    }
}