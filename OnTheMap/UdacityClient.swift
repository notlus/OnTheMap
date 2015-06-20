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
    
    func loginWithUser(username: String, password: String, completion: (Bool, String?) -> Void) -> Void {
        // Create the request
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.BaseURL)/session")!)
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
            var userID: String? = nil
            
            if let error = error {
                println("Request failed, error: \(error)")
                completion(false, userID)
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
                            
                            // Get the key (user ID) for the logged in user
                            if let account = parsedResult[ResponseKeys.Account] as? [String: AnyObject],
                                let key = account[ResponseKeys.Key] as? String {
                                println("Got user key (ID): \(key)")
                                userID = key
                            }
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
                        println("Error: '\(errorString)'")
                    }
                }
                else {
                    println("Failed to parse response")
                    success = false
                }
                
                // Call the completion handler
                completion(success, userID)
            }
        })
        
        task.resume()
    }
    
    func logout(completion: (Bool) -> Void) {
        // Create the request
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.BaseURL)/session")!)
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                println("Error in logout request")
            }
            else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                println("newData=\(newData)")
                var parseError: NSError? = nil
                completion(true)
            }
        })
        
        task.resume()
    }
    
    func getUserData(userID: String, completion: ([String: AnyObject]?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.BaseURL)/users/\(userID)")!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            var userData: [String: AnyObject]? = nil
            
            if let error = error {
                println("Failed to get user data, error=\(error)")
            } else {
                println("Got user data successfully")
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                var parseError: NSError? = nil
                if let parsedResult = NSJSONSerialization.JSONObjectWithData(newData,
                        options: NSJSONReadingOptions.AllowFragments,
                        error: &parseError) as? [String: AnyObject] {
                            userData = parsedResult["user"] as? [String: AnyObject]
                }
            }
            
            completion(userData)
        })
        
        task.resume()
    }
}

extension UdacityClient {

    struct Constants {
        static let BaseURL = "https://www.udacity.com/api"
        static let SignupURL = "https://www.udacity.com/account/auth#!/signup"
        static let UserDataURL = "https://www.udacity.com/api/users"
        static let FacebookAppID = "365362206864879"
    }
    
    struct BodyKeys {
        static let Root = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct ResponseKeys {
        static let Session = "session"
        static let Account = "account"
        static let Key = "key"
        static let SessionID = "id"
        static let Status = "status"
        static let Error = "error"
    }

}
