//
//  InfoPostingViewController.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 6/13/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import UIKit
import MapKit

class InfoPostingViewController: UIViewController, UITextViewDelegate {

    // MARK: Outlets
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var searchView: UITextView!
    @IBOutlet weak var questionsView: UIView!
    @IBOutlet weak var postingView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var urlTextView: UITextView!
    
    var mapDelegate: UpdateStudentMap?
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private enum PostingState: Int {
        // Show UI for finding a location
        case FindLocation = 1
        
        // Show UI for posting a location
        case PostLocation = 2
    }
    
    private let kSearchViewText = "Enter a location"
    private let kSearchViewTag = 1
    private let kURLViewText = "Enter a URL to post"
    private let kURLViewTag = 2
    
    private var postingState = PostingState.FindLocation
    private var postLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the font on the prompt text
        
        // Thin font
        let thinFont = UIFont(name: "Roboto-Thin", size: 36.0)!
        
        // Bold font
        let mediumFont = UIFont(name: "Roboto-Medium", size: 36.0)!

        // Regular font
        let regularFont = UIFont(name: "Roboto-Regular", size: 36.0)!

        // Get existing text from the label
        let promptText =  promptLabel.attributedText as! NSMutableAttributedString
        
        // Set the thin font on the entire text
        promptText.addAttribute(NSFontAttributeName, value: thinFont, range: NSRange(location: 0, length: promptText.length))
        
        // Set part of the text to use use the mediume font
        promptText.addAttribute(NSFontAttributeName, value: mediumFont, range: NSRange(location: 13, length: 9))
        
        // Set the modified text on the label
        promptLabel.attributedText = promptText
        
        /// Set up the search text view
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        paragraphStyle.paragraphSpacingBefore = 27.0

        searchView.textContainerInset = UIEdgeInsetsMake(60, 0, 0, 0)
        let searchTextAttributes = NSMutableAttributedString(string: kSearchViewText)
        let searchRange = NSRange(location: 0, length: searchTextAttributes.length)
        searchTextAttributes.addAttribute(NSFontAttributeName, value: thinFont, range: searchRange)
        searchTextAttributes.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: searchRange)
        searchTextAttributes.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: searchRange)
        searchView.attributedText = searchTextAttributes
        searchView.delegate = self
        
        /// Set up the URL text view
        urlTextView.textContainerInset = UIEdgeInsetsMake(60, 0, 0, 0)
        let urlTextAttributes = NSMutableAttributedString(string: kURLViewText)
        let urlRange = NSRange(location: 0, length: urlTextAttributes.length)
        urlTextAttributes.addAttribute(NSFontAttributeName, value: thinFont, range: urlRange)
        urlTextAttributes.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: urlRange)
        urlTextAttributes.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: urlRange)
        urlTextView.attributedText = urlTextAttributes
        urlTextView.delegate = self
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
    
    @IBAction func findOnMap() {
        println("findOnMap")
        
        view.endEditing(true)
        
        if !searchView.text.isEmpty && searchView.text != kSearchViewText, let searchText = searchView.text {
            // Hide the search field
            questionsView.hidden = true
            activityView.startAnimating()
            let gc = CLGeocoder()
            gc.geocodeAddressString(searchText, completionHandler: { (placemarks, geocodeError) -> Void in
                // Per the documentation, this is always called on the main queue
                
                println("Completed search request")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activityView.stopAnimating()
                })
                
                if let error = geocodeError {
                    println("Error in search, \(error.description)")
                    self.questionsView.hidden = false
                    self.showErrorAlert("Search Error", alertMessage: "Unable to find location")
                }
                else if let mapItem = placemarks.first as? CLPlacemark {
                    println("Successfully geocoded a location")
                    let placemark = MKPlacemark(placemark: mapItem)
                    
                    self.postLocation = mapItem.location
                    
                    self.postingState = PostingState.PostLocation
                    
                    // Show the item on a map
                    self.postingView.hidden = false
                    self.mapView.addAnnotation(placemark)
                    self.mapView.setCenterCoordinate(mapItem.location.coordinate, animated: true)
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
    }
    
    @IBAction func submitURL() {
        if !urlTextView.text.isEmpty, let urlToPost = NSURL(string: urlTextView.text) {
            println("url to post: \(urlToPost)")
            if UIApplication.sharedApplication().canOpenURL(urlToPost) {
                println("URL \(urlToPost) is valid!")
                
                activityView.startAnimating()
                
                // Get the info about the current user
                let udacityClient = UdacityClient()
                udacityClient.getUserData(appDelegate.userID!, completion: { (userData, error) -> Void in
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
                        studentInfo["mapString"] = self.searchView.text
                        
                        // Post a new location to the Parse API
                        let parseAPI = StudentInfoParseClient()
                        parseAPI.postStudentLocation(studentInfo) { (success, studentInformation) -> Void in
                            println("Posting complete, success=\(success)")
                            if let si = studentInformation {
                                // Call the delegate to update the map
                                self.mapDelegate?.addToMap(si)
                            }
                            
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    } else {
                        if let error = error {
                            println("Failed to post student info, error=\(error.description)")
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.activityView.stopAnimating()
                            self.showErrorAlert("Posting Error", alertMessage: "Unable to post information, please try again")
                        })
                    }
                })
            } else {
                showErrorAlert("Invalid URL", alertMessage: "Please enter a valid URL")
            }
        } else {
            showErrorAlert("Missing URL", alertMessage: "Please provide a URL")
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
        } //else {
//            if submitButton.frame.origin.y == 0 {
                // Subtract the height of the keyboard from the y-coordinate of the view
//                submitButton.frame.origin.y -= getKeyboardHeight(notification)
//            }
//        }
    }
    
    func keyboardWillHide(notification: NSNotification) -> Void {
        println("keyboardWillHide")
        
        if postingState == PostingState.FindLocation {
            if view.frame.origin.y < 0 {
                // Add the height of the keyboard to the y-coordinate of the view
                view.frame.origin.y += getKeyboardHeight(notification)
            }
        } //else {
            // Only move the button, so the URL text field does not scroll
//            if findButton.frame.origin.y < 0 {
//                // Add the height of the keyboard to the y-coordinate of the view
//                findButton.frame.origin.y += getKeyboardHeight(notification)
//            }
//        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let value = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return value.CGRectValue().size.height
    }
}

extension InfoPostingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textView.tag == kSearchViewTag ? kSearchViewText : kURLViewText
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            // Return was tapped
            textView.resignFirstResponder()
            
            if textView.tag == kSearchViewTag {
                findOnMap()
            } else {
                submitURL()
            }
            
            return false
        }
        
        return true
    }
}
