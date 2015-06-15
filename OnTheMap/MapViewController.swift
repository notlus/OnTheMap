//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/15/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let stlClient = StudentLocationClient()
        stlClient.getStudentLocations { (locations) -> Void in
            println("Student location completion handler")
            if locations.isEmpty {
                println("No student locations")
            }
            else {
                // Save the location data
                self.appDelegate.studentLocations = locations
                
                // Update the map
                self.addAnnotations()
            }
        }
        
        // Create the pin button
        let buttonImage = UIImage(named: "pin")!
        let postPinButton = UIBarButtonItem(image: buttonImage, landscapeImagePhone: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: "postPin")
        var rightButtons = navigationItem.rightBarButtonItems! as! [UIBarButtonItem]
        rightButtons.append(postPinButton)
        navigationItem.rightBarButtonItems = rightButtons
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func refresh(sender: AnyObject) {
        println("refresh")
    }

    private func addAnnotations() -> Void {
        for student in appDelegate.studentLocations {
            let annotation = MKPointAnnotation()
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            
            // Add the annotation on the main queue
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mapView.addAnnotation(annotation)
            })
        }
    }
    
    // TODO: This should be shared between this view controller and the table view controller
    func postPin() -> Void {
        println("postPin")
        performSegueWithIdentifier("ShowPostingView", sender: self)
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var v = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "test") as MKPinAnnotationView
        v.pinColor = .Green
        v.canShowCallout = true
        v.animatesDrop = true
        v.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.InfoLight) as! UIButton
        return v
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        println("calloutAccessoryControlTapped")
        if let urlString = view.annotation.subtitle {
            if let url = validateURL(urlString) {
                UIApplication.sharedApplication().openURL(url)
            }
            else {
                let alertView = UIAlertView(title: "Invalid URL", message: "Invalid URL: \(urlString)", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
        }
    }
}
