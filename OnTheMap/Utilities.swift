//
//  Utilities.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 6/14/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import Foundation

func validateURL(urlString: String) -> NSURL? {
    if let url = NSURL(string: urlString) {
        if let scheme = url.scheme {
            if (scheme as NSString).substringToIndex(4) != "http" || url.host == nil {
                println("Invalid URL: \(scheme)")
                return nil
            }
        }

        return url
    }
    
    return nil
}
