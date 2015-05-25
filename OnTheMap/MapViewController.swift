//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/15/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import MapKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the pin button
        let postPinButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "postPin")
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

    // TODO: This should be shared between this view controller and the table view controller
    func postPin() -> Void {
        println("postPin")
    }
}

