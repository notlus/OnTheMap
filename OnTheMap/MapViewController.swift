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
                self.addAnnotations(locations)
            }
        }
        
        // Create the pin button
        let postPinButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "postPin")
        var rightButtons = navigationItem.rightBarButtonItems! as! [UIBarButtonItem]
        rightButtons.append(postPinButton)
        navigationItem.rightBarButtonItems = rightButtons

//        let student = StudentInformation(createdAt: "aaa", firstName: "Jeffrey", lastName: "Sulton", latitude: "34.05", longitude: "-118.25",
//            mapString: "Map String", mediaURL: "https://apple.com", objectID: "aa", uniqueKey: "aa", updatedAt: "aa")
//        let annotation = MKPointAnnotation()
//        annotation.title = student.mapString
//        annotation.subtitle = "https://"
//        let coord = CLLocationCoordinate2D(latitude: NSNumberFormatter().numberFromString(student.latitude)!.doubleValue, longitude: NSNumberFormatter().numberFromString(student.longitude)!.doubleValue)
//        annotation.coordinate = coord
//        mapView.addAnnotation(annotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func refresh(sender: AnyObject) {
        println("refresh")
    }

    private func addAnnotations(students: [StudentInformation]) -> Void {
        for student in students {
            let annotation = MKPointAnnotation()
            annotation.title = student.mapString
            annotation.subtitle = student.mediaURL
            let coord = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            annotation.coordinate = coord
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mapView.addAnnotation(annotation)
            })
        }
    }
    
    // TODO: This should be shared between this view controller and the table view controller
    func postPin() -> Void {
        println("postPin")
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
        if let urlString = view.annotation.subtitle,
            let studentURL = NSURL(string: urlString) {
                if validateURL(studentURL) {
                    UIApplication.sharedApplication().openURL(studentURL)
                }
                else {
                    let alertView = UIAlertView(title: "Invalid URL", message: "Invalid URL: \(urlString)", delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                }
        }
    }
    
    private func validateURL(url: NSURL) -> Bool {
        if let scheme = url.scheme {
            if (scheme as NSString).substringToIndex(4) != "http" || url.host == nil {
                println("Invalid URL: \(scheme)")
                return false
            }
        }
        
        return true
    }
}
