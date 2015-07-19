//
//  StudentLocationClient.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/25/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import UIKit

/// Uses Parse to get/post student data

class StudentLocationClient: NSObject {
    var session: NSURLSession
    var allStudents = [StudentInformation]()
    
    override init() {
        session = NSURLSession.sharedSession()
    }
    
    func getStudentLocations(completion: (ErrorType) -> Void) -> Void {
        // Create the request
        let parameters = [RequestKeys.limit: 100]
        
        let urlString = "\(Constants.BaseURL)?\(StudentLocationClient.escapedParameters(parameters))"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "GET"
        
        // Add headers
        request.addValue(Constants.AppID, forHTTPHeaderField: Constants.AppIDHeader)
        request.addValue(Constants.APIKey, forHTTPHeaderField: Constants.APIKeyHeader)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            var studentInformation: [StudentInformation]?
            var errorType = ErrorType.Unknown
            var success = false

            if error != nil {
                println("error in request: \(error)")
                if error.code == NSURLErrorNotConnectedToInternet {
                    errorType = ErrorType.Network
                } else {
                    errorType = ErrorType.DownLoad
                }
            }
            else {
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                // Deserialize into a dictionary
                var parseError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as! [String: AnyObject]
                println("parsedResult = \(parsedResult)")
                let studentLocations = parsedResult[Constants.ResultsKey] as! [[String: AnyObject]]
                
                // Create the array and append `StudentInformation` instances
                for entry in studentLocations {
                    self.allStudents.append(StudentInformation(studentInfo: entry))
                }
                
                errorType = ErrorType.Success
            }
            
            // Always call the completion handler
            completion(errorType)
        })
        
        task.resume()
    }
    
    func postStudentLocation(studentLocation: [String: AnyObject], completion: (Bool, StudentInformation?) -> Void) -> Bool {
        let urlString = "\(Constants.BaseURL)"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        
        // Add headers
        request.addValue(Constants.AppID, forHTTPHeaderField: Constants.AppIDHeader)
        request.addValue(Constants.APIKey, forHTTPHeaderField: Constants.APIKeyHeader)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        // Add body data
        var error: NSError?
        let jsonData = NSJSONSerialization.dataWithJSONObject(studentLocation as [String: AnyObject], options: NSJSONWritingOptions.PrettyPrinted, error: &error)
        
        // TODO: Remove after testing
        let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)
        println("JSON data to post is \(jsonString)")
        
        request.HTTPBody = jsonData
        
        // Create the task
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            var success = false
            var siResult: StudentInformation? = nil
            
            if let postError = error {
                println("Error posting data")
                success = false
            } else {
                println("Posted data successfully")
                var err: NSError?
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &err) as! [String: AnyObject]
                var si = studentLocation
                si["objectId"] = parsedResult["objectId"]
                si["createdAt"] = parsedResult["createdAt"]
                
                // Create new `StudentInformation` instance
                siResult = StudentInformation(studentInfo: si)
                success = true
            }

            // Always call the completion handler
            // TODO: Since siResult is an optional, don't really need success
            completion(success, siResult)
        })
        
        task.resume()
        
        return false
    }
    
    func queryStudentLocation(queryString: String) -> [StudentInformation] {
        return []
    }
    
    func updateStudentLocation(studentLocation: StudentInformation) -> Bool {
        return false
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }

}

extension StudentLocationClient {
    
    struct Constants {
        static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let BaseURL = "https://api.parse.com/1/classes/StudentLocation"
        static let AppIDHeader = "X-Parse-Application-Id"
        static let APIKeyHeader = "X-Parse-REST-API-Key"
        static let ResultsKey = "results"
    }
    
    struct RequestKeys {
        static let limit = "limit"
    }
    
    enum ErrorType {
        case Success
        case Network  // No network
        case DownLoad // Download failure
        case Unknown
    }
}