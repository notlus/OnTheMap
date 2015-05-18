//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/17/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import Foundation

/// A client for working with the Udacity API
class UdacityClient: NSObject {
    var session: NSURLSession
    
    /// The session ID for accessing the Udacity API
    var sessionID: String? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func loginWithUser(username: String, password: String, completion: (Bool) -> Void) -> Void {
        completion(true)
    }
}

extension UdacityClient {

struct Constants {
    let BaseURL = "https://www.udacity.com/api/session"
}

}
