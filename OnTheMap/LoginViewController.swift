//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/15/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var udacityClient: UdacityClient?

    override func viewDidLoad() {
        super.viewDidLoad()

        udacityClient = UdacityClient()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func login(sender: AnyObject) {
        println("login")
        if !usernameTextField.text.isEmpty && !passwordTextField.text.isEmpty {
            udacityClient?.loginWithUser(usernameTextField.text, password: passwordTextField.text, completion: { (success) -> Void in
                if success {
                    println("Logged in successfully")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("OnTheMapHome", sender: self)
                    })
                }
                else {
                    println("Failed to log in")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.handleInvalidLogin()
                    })
                }
            })
        }
        else {
            println("Invalid username or password")
            handleInvalidLogin()
        }
    }

    @IBAction func logout(unwindSegue: UIStoryboardSegue) {
        println("logout")
    }
    
    func handleInvalidLogin() -> Void {
        let alert = UIAlertController(title: "Login failed", message: "Invalid username or password", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Create actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            println("Ok action taken")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            println("Cancel action taken")
        })
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "OnTheMapHome" {
            println("OnTheMap segue")
        }
        
        // Pass the selected object to the new view controller.
    }
}
