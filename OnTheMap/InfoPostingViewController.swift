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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postingState = PostingState.FindLocation
        
        let font = UIFont(name: "Roboto-Thin", size: 37.0)!
        let attributes = [ NSFontAttributeName: font ]
        promptLabel.attributedText = NSAttributedString(string: promptLabel.attributedText.string, attributes: attributes)
        
        // Set this class as the delegate for the search text field
        searchField.delegate = self
        urlTextField.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func handleSingleTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func findOnMap(sender: AnyObject) {
        println("findOnMap")
        
        if postingState == PostingState.FindLocation {
            println("PostingState.FindLocation")
            
            if !searchField.text.isEmpty, let searchText = searchField.text {
                // Hide the search field
                searchField.hidden = true
                activityView.startAnimating()
                let gc = CLGeocoder()
                gc.geocodeAddressString(searchText, completionHandler: { (placemarks, geocodeError) -> Void in
                    // Per the documentation, this is always called on the main queue
                    
                    println("Completed search request")
                    
                    // Stop activity view
                    self.activityView.stopAnimating()
                    
                    if let error = geocodeError {
                        println("Error in search, \(error.description)")
                        self.searchField.hidden = false
                        self.showErrorAlert("Search Error", alertMessage: "Unable to find location")
                    }
                    else if let mapItem = placemarks.first as? CLPlacemark {
                        println("Successfully geocoded a location")
                        let placemark = MKPlacemark(placemark: mapItem)
                        
                        self.postLocation = mapItem.location
                        
                        self.postingState = PostingState.PostLocation
                        
                        // Show the item on a map
                        self.promptLabel.hidden = true
                        self.mapView.hidden = false
                        self.urlTextField.hidden = false
                        self.mapView.addAnnotation(placemark)
                        self.mapView.setCenterCoordinate(mapItem.location.coordinate, animated: true)
                        self.findOrSubmit.setTitle("Submit", forState: UIControlState.Normal)
                    }
                    else {
                        // No placemarks
                        println("No placemarks returned")
                        self.showErrorAlert("Error", alertMessage: "No placemarks found")
                    }
                })
            }
            else {
                showErrorAlert("Search", alertMessage: "Please enter an address or location of interest")
            }
        } else if postingState == PostingState.PostLocation {
            println("PostingState.PostLocation")
            
            if !urlTextField.text.isEmpty, let urlToPost = NSURL(string: urlTextField.text) {
                println("url to post: \(urlToPost)")
                if UIApplication.sharedApplication().canOpenURL(urlToPost) {
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
                            studentInfo["mediaURL"] = urlToPost.absoluteString
                            studentInfo["mapString"] = self.searchField.text
                            
                            // Post a new location to the Parse API
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
                    showErrorAlert("Invalid URL", alertMessage: "Please enter a valid URL")
                }
            } else {
                showErrorAlert("Missing URL", alertMessage: "Please provide a URL")
            }
        } else {
            fatalError("Invalid state!")
        }
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func showErrorAlert(alertTitle: String, alertMessage: String) -> Void {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func subscribeToKeyboardNotifications() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() -> Void {
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillShowNotification)
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillHideNotification)
    }
    
    // MARK: Keyboard notification handlers
    
    func keyboardWillShow(notification: NSNotification) -> Void {
        println("keyboardWillShow")
        
        if postingState == PostingState.FindLocation {
            if view.frame.origin.y == 0 {
                // Subtract the height of the keyboard from the y-coordinate of the view
                view.frame.origin.y -= getKeyboardHeight(notification)
            }
        } else {
            if findOrSubmit.frame.origin.y == 0 {
                // Subtract the height of the keyboard from the y-coordinate of the view
                findOrSubmit.frame.origin.y -= getKeyboardHeight(notification)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) -> Void {
        println("keyboardWillHide")
        
        if postingState == PostingState.FindLocation {
            if view.frame.origin.y < 0 {
                // Add the height of the keyboard to the y-coordinate of the view
                view.frame.origin.y += getKeyboardHeight(notification)
            }
        } else {
            // Only move the button, so the URL text field does not scroll
            if findOrSubmit.frame.origin.y < 0 {
                // Add the height of the keyboard to the y-coordinate of the view
                findOrSubmit.frame.origin.y += getKeyboardHeight(notification)
            }
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let value = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return value.CGRectValue().size.height
    }
}

extension InfoPostingViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        findOnMap(self)
        return true
    }
}
