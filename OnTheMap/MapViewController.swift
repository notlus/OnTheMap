//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/15/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import MapKit

/// A protocol that can be used to trigger an update to the map
protocol UpdateStudentMap {
    
    func addToMap(studentInformation: StudentInformation)
    
}

class MapViewController: UIViewController, MKMapViewDelegate, UpdateStudentMap {
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadStudents()
        
        // Create the pin button
        let buttonImage = UIImage(named: "pin")!
        let postPinButton = UIBarButtonItem(image: buttonImage, landscapeImagePhone: buttonImage,
                                            style: UIBarButtonItemStyle.Plain, target: self,
                                            action: "postPin")
        
        var rightButtons = navigationItem.rightBarButtonItems! as! [UIBarButtonItem]
        rightButtons.append(postPinButton)
        navigationItem.rightBarButtonItems = rightButtons
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "handleNote", name: "test", object: nil)
    }
    
    func handleNote() -> Void {
        println("Handling test notification")
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
//        loadStudents()
//        center.addObserver(self, selector: "handleNote", name: "test", object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func refresh(sender: AnyObject) {
        println("refresh")
        loadStudents()
    }

    private func loadStudents() {
        activityView.startAnimating()
        appDelegate.studentInfoClient.getStudentLocations { (errorType) -> Void in
            println("Student location completion handler")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.activityView.stopAnimating()
            })
            
            if errorType == StudentInfoParseClient.ErrorType.Success {
                self.addAnnotations()
            } else {
                // An error occurred
                
                let alertTitle: String
                let alertMessage: String
                if errorType == StudentInfoParseClient.ErrorType.DownLoad {
                    alertTitle = "Download Error"
                    alertMessage = "Unable to download stundet data"
                } else if errorType == StudentInfoParseClient.ErrorType.Network {
                    alertTitle = "Network Error"
                    alertMessage = "No network connection detected"
                } else {
                    alertTitle = "Unknown error"
                    alertMessage = "An unexpected error occurred"
                }
                
                println("Download error")
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
                let retryAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                    println("Inside retry alert action handler")
                    self.loadStudents()
                })

                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
                    println("Inside cancel alert action handler")
                })
                
                alert.addAction(retryAction)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func addAnnotations() -> Void {
        // Remove existing annotations
        self.mapView.removeAnnotations(self.mapView.annotations)

        for student in appDelegate.studentInfoClient.allStudents {
            addAnnotation(student)
        }
    }
    
    private func addAnnotation(student: StudentInformation) {
        let annotation = MKPointAnnotation()
        annotation.title = "\(student.firstName) \(student.lastName)"
        annotation.subtitle = student.mediaURL
        annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
        
        // Add the annotation on the main queue
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.mapView.addAnnotation(annotation)
        })
    }
    
    // TODO: This should be shared between this view controller and the table view controller
    func postPin() -> Void {
        println("postPin")
        performSegueWithIdentifier("ShowPostingView", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPostingView" {
            let destination = segue.destinationViewController as! InfoPostingViewController
            destination.mapDelegate = self
        }
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var v = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MapViewAnnotation") as MKPinAnnotationView
        v.pinColor = .Green
        v.canShowCallout = true
        v.animatesDrop = true
        v.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.InfoLight) as! UIButton
        return v
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        println("calloutAccessoryControlTapped")
        if let urlString = view.annotation.subtitle,
            let url = NSURL(string: urlString) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
            else {
                let alertView = UIAlertView(title: "Invalid URL", message: "Invalid URL: \(urlString)", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
        }
    }
}

// MARK: UpdateStudentMap implementation

extension MapViewController {
    func addToMap(studentInformation: StudentInformation) {
        self.appDelegate.studentInfoClient.allStudents.append(studentInformation)
        addAnnotation(studentInformation)
    }
}
