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
        // Create the request
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.BaseURL)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            BodyKeys.Root: [
                BodyKeys.Username: username,
                BodyKeys.Password: password
            ]
        ]
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: nil, error: nil)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                println("Request failed, error: \(error)")
                completion(false)
            }
            else {
                // Default success to false
                var success: Bool = false
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                var parseError: NSError? = nil
                if let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as? [String: AnyObject] {
                    if let session = parsedResult[ResponseKeys.Session] as? [String: AnyObject] {
                        if let sessionID = session[ResponseKeys.SessionID] as? String {
                            self.sessionID = sessionID
                            success = true
                        }
                        else {
                            success = false
                        }
                    }
                    else {
                        // Check the status code
                        let status = parsedResult[ResponseKeys.Status] as! Int
                        success = false
                        let errorString = parsedResult[ResponseKeys.Error] as! String
                        println("Error is \(errorString)")
                    }
                }
                else {
                    println("Failed to parse response")
                    success = false
                }
                
                // Call the completion handler
                completion(success)
            }
        })
        
        task.resume()
    }
}

extension UdacityClient {

    struct Constants {
        static let BaseURL = "https://www.udacity.com/api/session"
        static let SignUpURL = "https://www.udacity.com/account/auth#!/signup"
    }
    
    struct BodyKeys {
        static let Root = "udacity"
        static let Username = "username"
        static let Password = "password"
        // = "{\"udacity\": {\"username\": \"account@domain.com\", \"password\": \"********\"}}".dataUsingEncoding(NSUTF8StringEncoding)
    }
    struct ResponseKeys {
        static let Session = "session"
        static let SessionID = "id"
        static let Status = "status"
        static let Error = "error"
    }

}
