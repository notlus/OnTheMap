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
    
    @IBAction func refresh(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the pin button
        let buttonImage = UIImage(named: "pin")!
        let postPinButton = UIBarButtonItem(image: buttonImage, landscapeImagePhone: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: "postPin")
        var rightButtons = navigationItem.rightBarButtonItems! as! [UIBarButtonItem]
        rightButtons.append(postPinButton)
        navigationItem.rightBarButtonItems = rightButtons

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func postPin() -> Void {
        println("postPin")
        performSegueWithIdentifier("ShowPostingView", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return appDelegate.studentLocations.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mapCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        let studentLocation = appDelegate.studentLocations[indexPath.row]
        cell.textLabel?.text = studentLocation.mapString
        cell.detailTextLabel?.text = studentLocation.mediaURL

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = appDelegate.studentLocations[indexPath.row]
        if let url = NSURL(string: studentLocation.mediaURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
