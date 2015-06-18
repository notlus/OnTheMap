//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/15/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // MARK: Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var udacityClient: UdacityClient?

    override func viewDidLoad() {
        super.viewDidLoad()

        udacityClient = UdacityClient()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handleSingleTap(sender: AnyObject) {
        println("handleSingleTap")
        view.endEditing(true)
    }
    
    @IBAction func login(sender: AnyObject) {
        println("login")
        if !usernameTextField.text.isEmpty && !passwordTextField.text.isEmpty {
            udacityClient?.loginWithUser(usernameTextField.text, password: passwordTextField.text, completion: { (success, userID) -> Void in
                if success {
                    println("Logged in successfully with user ID \(userID!)")
                    self.appDelegate.userID = userID
                    
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
        
        udacityClient!.logout { (success) -> Void in
            if success {
                // Clear the session ID
                self.udacityClient?.sessionID = nil
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                })
            }
        }
    }
    
    @IBAction func signUp() {
        println("signUp")
        if !UIApplication.sharedApplication().openURL(NSURL(string: UdacityClient.Constants.SignupURL)!) {
            println("Failed to open URL")
        }
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

    private func subscribeToKeyboardNotifications() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() -> Void {
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillShowNotification)
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillHideNotification)
    }

    // MARK: Keyboard notification handlers
    
    func keyboardWillShow(notification: NSNotification) -> Void {
        println("keyboardWillShow")
    }

    func keyboardWillHide(notification: NSNotification) -> Void {
        println("keyboardWillHide")
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let value = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return value.CGRectValue().size.height
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
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
