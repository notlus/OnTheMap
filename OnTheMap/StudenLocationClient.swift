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
    
    func getStudentLocations(completion: ([StudentInformation]) -> Void) -> Void {
        // Create the request
        let urlString = "\(Constants.BaseURL)?\(RequestKeys.limit)=100"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        // Add headers
        request.addValue(Constants.AppID, forHTTPHeaderField: Constants.AppIDHeader)
        request.addValue(Constants.APIKey, forHTTPHeaderField: Constants.APIKeyHeader)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                println("error in request")
            }
            else {
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                // Deserialize into a dictionary
                var parseError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError) as! [String: AnyObject]
                println("parsedResult = \(parsedResult)")
                let studentLocations = parsedResult[Constants.ResultsKey] as! [[String: AnyObject]]
                
                var studentInformation = [StudentInformation]()
                for entry in studentLocations {
                    studentInformation.append(StudentInformation(studentInfo: entry))
                }
                
                // Call the completion handler
                completion(studentInformation)
            }
        })
        
        task.resume()
    }
    
    func postStudentLocation(studentLocation: StudentInformation) -> Bool {
        return false
    }
    
    func queryStudentLocation(queryString: String) -> [StudentInformation] {
        return []
    }
    
    func updateStudentLocation(studentLocation: StudentInformation) -> Bool {
        return false
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
    
}