//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/15/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import MapKit

protocol UpdateStudentMap {
    
    func addToMap(studentInformation: StudentInformation)
    
}

class MapViewController: UIViewController, MKMapViewDelegate, UpdateStudentMap {
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadStudents()
        
        // Create the pin button
        let buttonImage = UIImage(named: "pin")!
        let postPinButton = UIBarButtonItem(image: buttonImage, landscapeImagePhone: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: "postPin")
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
        let stlClient = StudentLocationClient()
        stlClient.getStudentLocations { (studentLocations) -> Void in
            println("Student location completion handler")
            if let locations = studentLocations {
                // Save the location data
                self.appDelegate.studentLocations = locations
                
                self.addAnnotations()
            } else {
                println("No student locations")
                // TODO: Use UIAlertController
                let alert = UIAlertView(title: "Error", message: "Unable to download student locations", delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
            }
        }
    }
    
    private func addAnnotations() -> Void {
        // Remove existing annotations
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        for student in appDelegate.studentLocations {
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
        let destination = segue.destinationViewController as! InfoPostingViewController
        destination.mapDelegate = self
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

// MARK: UpdateStudentMap implementation

extension MapViewController {
    func addToMap(studentInformation: StudentInformation) {
        self.appDelegate.studentLocations.append(studentInformation)
        addAnnotation(studentInformation)
    }
}
