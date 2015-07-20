//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/15/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    // MARK: Outlets
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func refresh(sender: AnyObject) {
        println("refresh")
        loadStudents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the pin button
        let buttonImage = UIImage(named: "pin")!
        let postPinButton = UIBarButtonItem(image: buttonImage, landscapeImagePhone: buttonImage,
                                            style: UIBarButtonItemStyle.Plain, target: self,
                                            action: "postPin")
        
        var rightButtons = navigationItem.rightBarButtonItems! as! [UIBarButtonItem]
        rightButtons.append(postPinButton)
        navigationItem.rightBarButtonItems = rightButtons
    }

    func postPin() -> Void {
        println("postPin")
        performSegueWithIdentifier("ShowPostingView", sender: self)
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return appDelegate.studentInfoClient.allStudents.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mapCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        let studentLocation = appDelegate.studentInfoClient.allStudents[indexPath.row]
        cell.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.imageView?.image = UIImage(named: "pin")

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = appDelegate.studentInfoClient.allStudents[indexPath.row]
        if let url = NSURL(string: studentLocation.mediaURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    private func loadStudents() {
        activityView.startAnimating()
        appDelegate.studentInfoClient.getStudentLocations { (errorType) -> Void in
            println("Student location completion handler")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.activityView.stopAnimating()
            })
            
            if errorType == StudentInfoParseClient.ErrorType.Success {
                // Retrieved student data, update the table view
                self.tableView.reloadData()
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
}
