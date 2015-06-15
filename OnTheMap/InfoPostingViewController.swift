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

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findOrSubmit: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    
    private enum PostingState {
        case FindLocation
        
        case PostLocation
    }
    
    private var postingState = PostingState.FindLocation
    
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
            } else {
                let alert = UIAlertView(title: "Error", message: "Invalid URL", delegate: nil, cancelButtonTitle: "Ok")
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
