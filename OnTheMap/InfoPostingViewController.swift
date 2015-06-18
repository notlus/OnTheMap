//
//  InfoPostingViewController.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 6/13/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import UIKit
import MapKit

class InfoPostingViewController: UIViewController {
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findOrSubmit: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    
    private enum PostingState {
        // Show UI for finding a location
        case FindLocation
        
        // Show UI for posting a location
        case PostLocation
    }
    
    private var postingState = PostingState.FindLocation
    private var postLocation: CLLocation?
    
    @IBAction func findOnMap(sender: AnyObject) {
        println("findOnMap")
        
        if postingState == PostingState.FindLocation {
            println("PostingState.FindLocation")
            
            if !searchField.text.isEmpty, let searchText = searchField.text {
                // Hide the search field
                searchField.hidden = true
                let searchRequest = MKLocalSearchRequest()
                searchRequest.naturalLanguageQuery = searchText
                let localSearch = MKLocalSearch(request: searchRequest)
                localSearch.startWithCompletionHandler({ (searchResponse, searchError) -> Void in
                    println("Completed search request")
                    if let error = searchError {
                        println("Error in search, \(error.description)")
                        self.searchField.hidden = false
                        // Show the alert on the main queue
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let alert = UIAlertView(title: "Search Error", message: error.description, delegate: nil, cancelButtonTitle: "Ok")
                            alert.show()
                        })
                    }
                    else {
                        println("Successful local search")
                        if let mapItem = searchResponse.mapItems.first as? MKMapItem {
                            
                            self.postLocation = mapItem.placemark.location
                            
                            self.postingState = PostingState.PostLocation
                            
                            // Show the item on a map
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.promptLabel.hidden = true
                                self.mapView.hidden = false
                                self.urlTextField.hidden = false
                                self.mapView.addAnnotation(mapItem.placemark)
                                self.mapView.setCenterCoordinate(mapItem.placemark.location.coordinate, animated: true)
                                self.findOrSubmit.setTitle("Submit", forState: UIControlState.Normal)
                            })
                        }
                    }
                })
            }
            else {
                let alert = UIAlertView(title: "Error", message: "Invalid search request", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        } else if postingState == PostingState.PostLocation {
            println("PostingState.PostLocation")
            
            if !urlTextField.text.isEmpty, let urlToPost = urlTextField.text {
                println("url to post: \(urlToPost)")
                if let url = validateURL(urlToPost) {
                    println("URL \(urlToPost) is valid!")
                    
                    // Get the info about the current user
                    let udacityClient = UdacityClient()
                    udacityClient.getUserData(appDelegate.userID!, completion: { (userData) -> Void in
                        if let userData = userData {
                            println("Got user data: \(userData)")
                            
                            var si1 = [String: AnyObject]()
                            si1["firstName"] = userData["first_name"]
                            si1["lastName"] = userData["last_name"]
                            si1["latitude"] = self.postLocation?.coordinate.latitude ?? 0
                            si1["longitude"] = self.postLocation?.coordinate.longitude ?? 0
                            si1["mediaURL"] = urlToPost
                            si1["mapString"] = self.searchField.text
                            si1["uniqueKey"] = "1234"
                            
                            let si = StudentInformation(studentInfo: si1)
                            
                            // Post a new location to the Parse API
                            let parseAPI = StudentLocationClient()
                            
                            parseAPI.postStudentLocation(si) { (success) -> Void in
                                println("Posting complete, success=\(success)")
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        }
                    })
                } else {
                    let alert = UIAlertView(title: "Error", message: "Invalid URL", delegate: nil, cancelButtonTitle: "Ok")
                    alert.show()
                }
            } else {
                let alert = UIAlertView(title: "Error", message: "Missing URL", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        } else {
            fatalError("Invalid state!")
        }
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postingState = PostingState.FindLocation
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
