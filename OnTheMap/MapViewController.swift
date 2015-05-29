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

        // Create the pin button
        let postPinButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "postPin")
        var rightButtons = navigationItem.rightBarButtonItems! as! [UIBarButtonItem]
        rightButtons.append(postPinButton)
        navigationItem.rightBarButtonItems = rightButtons

        let student = StudentLocation(firstName: "Jeffrey", lastName: "Sulton", mapString: "Map String", mediaURL: "https://apple.com", latitude: 34.05, longitude: -118.25)
        let annotation = MKPointAnnotation()
        annotation.title = student.mapString
        annotation.subtitle = "https://"
        let coord = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
        annotation.coordinate = coord
//        let mapPoint = MKMapPointForCoordinate(coord)
        mapView.addAnnotation(annotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func refresh(sender: AnyObject) {
        println("refresh")
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
            let t = scheme as NSString
            if t.substringToIndex(4) != "http" || url.host == nil {
                println("Unsupported URL scheme: \(scheme)")
                return false
            }
        }
        
        return true
    }
}
