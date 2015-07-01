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

    // MARK: Outlets
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findOrSubmit: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var mapDelegate: UpdateStudentMap?
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
                activityView.startAnimating()
                let searchRequest = MKLocalSearchRequest()
                searchRequest.naturalLanguageQuery = searchText
                let localSearch = MKLocalSearch(request: searchRequest)
                localSearch.startWithCompletionHandler({ (searchResponse, searchError) -> Void in
                    println("Completed search request")
                    
                    // Stop activity view
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.activityView.stopAnimating()
                    })
                    
                    if let error = searchError {
                        println("Error in search, \(error.description)")
                        self.searchField.hidden = false
                        // Show the alert on the main queue
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let alert = UIAlertController(title: "Search Error", message: "Unable to find location", preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                            alert.addAction(okAction)
                            self.presentViewController(alert, animated: true, completion: nil)
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
                let alert = UIAlertController(title: "Search", message: "Please enter an address or location of interest", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(okAction)
                presentViewController(alert, animated: true, completion: nil)
            }
        } else if postingState == PostingState.PostLocation {
            println("PostingState.PostLocation")
            
            if !urlTextField.text.isEmpty, let urlToPost = urlTextField.text {
                println("url to post: \(urlToPost)")
                if let url = validateURL(urlToPost) {
                    println("URL \(urlToPost) is valid!")
                    
                    activityView.startAnimating()
                    
                    // Get the info about the current user
                    let udacityClient = UdacityClient()
                    udacityClient.getUserData(appDelegate.userID!, completion: { (userData) -> Void in
                        if let userData = userData {
                            println("Got user data: \(userData)")

                            // Create a dictionary containing the new user data
                            var studentInfo = [String: AnyObject]()
                            // TODO: Create constants for the keys
                            studentInfo["uniqueKey"] = "\(self.appDelegate.userID)"
                            studentInfo["firstName"] = userData["first_name"]
                            studentInfo["lastName"] = userData["last_name"]
                            studentInfo["latitude"] = self.postLocation?.coordinate.latitude ?? 0
                            studentInfo["longitude"] = self.postLocation?.coordinate.longitude ?? 0
                            studentInfo["mediaURL"] = urlToPost
                            studentInfo["mapString"] = self.searchField.text
                            
                            // Post a new location to the Parse API
                            // TODO: Can this be a static method
                            let parseAPI = StudentLocationClient()
                            parseAPI.postStudentLocation(studentInfo) { (success, studentInformation) -> Void in
                                println("Posting complete, success=\(success)")
                                if let si = studentInformation {
                                    // Call the delegate to update the map
                                    self.mapDelegate?.addToMap(si)
                                }
                                
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.activityView.stopAnimating()
                            })
                        }
                    })
                } else {
                    let alert = UIAlertController(title: "Invalid URL", message: "Please enter a valid URL", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alert.addAction(okAction)
                    presentViewController(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Missing URL", message: "Please provide a URL", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(okAction)
                presentViewController(alert, animated: true, completion: nil)
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
        
        let font = UIFont(name: "Roboto-Thin", size: 37.0)!
        let attributes = [ NSFontAttributeName: font ]
        promptLabel.attributedText = NSAttributedString(string: promptLabel.attributedText.string, attributes: attributes)
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
