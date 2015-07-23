//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jeffrey Sulton on 5/15/15.
//  Copyright (c) 2015 notlus. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private var udacityClient: UdacityClient?
    
    // MARK: Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        udacityClient = UdacityClient()

        let accessToken = FBSDKAccessToken.currentAccessToken()
        if accessToken != nil {
            println("Already logged in via Facebook")
        
            udacityClient?.loginWithFacebook(accessToken.tokenString, completion: { (errorType, userID) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activityView.stopAnimating()
                })
                
                switch errorType {
                case UdacityClient.ErrorType.Success:
                    println("Logged in successfully with user ID \(userID!)")
                    self.appDelegate.userID = userID
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("OnTheMapHome", sender: self)
                    })
                case UdacityClient.ErrorType.Authentication:
                    println("Authentication error")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.handleInvalidLogin()
                    })
                case UdacityClient.ErrorType.Network:
                    println("Network error")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.handleNetworkError()
                    })
                case UdacityClient.ErrorType.InvalidData:
                    println("Invalid data received")
                    assertionFailure("Invalid data received logging in")
                case UdacityClient.ErrorType.Unknown:
                    println("Unknown error")
                    assertionFailure("Unknown error logging in")
                }
            })
        }

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
    
    @IBAction func handleSingleTap(sender: AnyObject) {
        println("handleSingleTap")
        view.endEditing(true)
    }
    
    @IBAction func login(sender: AnyObject) {
        println("login")
        if !usernameTextField.text.isEmpty && !passwordTextField.text.isEmpty {
            activityView.startAnimating()
            udacityClient?.loginWithUser(usernameTextField.text, password: passwordTextField.text, completion: { (errorType, userID) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.activityView.stopAnimating()
                })
                
                self.handleLogin(errorType, userID: userID)
            })
        }
        else {
            println("Invalid username or password")
            handleInvalidLogin()
        }
    }

    @IBAction func logout(unwindSegue: UIStoryboardSegue) {
        println("logout")
        activityView.startAnimating()
        udacityClient!.logout { (success) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.activityView.stopAnimating()
            })
            
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
            println("OK action taken")
        })
        
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func handleNetworkError() -> Void {
        let alert = UIAlertController(title: "Login failed", message: "No network connection", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Create actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            println("OK action taken")
        }

        alert.addAction(okAction)
        
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

    private func handleLogin(errorType: UdacityClient.ErrorType, userID: String?) {
        switch errorType {
        case UdacityClient.ErrorType.Success:
            println("Logged in successfully with user ID \(userID!)")
            self.appDelegate.userID = userID
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("OnTheMapHome", sender: self)
            })
        case UdacityClient.ErrorType.Authentication:
            println("Authentication error")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.handleInvalidLogin()
            })
        case UdacityClient.ErrorType.Network:
            println("Network error")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.handleNetworkError()
            })
        case UdacityClient.ErrorType.InvalidData:
            println("Invalid data received")
            assertionFailure("Invalid data received logging in")
        case UdacityClient.ErrorType.Unknown:
            println("Unknown error")
            assertionFailure("Unknown error logging in")
        }
    }
    
    // MARK: Keyboard notification handlers
    
    func keyboardWillShow(notification: NSNotification) -> Void {
        println("keyboardWillShow")
        if view.frame.origin.y == 0 {
            // Subtract the height of the keyboard from the y-coordinate of the view
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) -> Void {
        println("keyboardWillHide")
        if view.frame.origin.y < 0 {
            // Add the height of the keyboard to the y-coordinate of the view
            view.frame.origin.y += getKeyboardHeight(notification)
        }
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
    
    // MARK: - FBSDKLoginButtonDelegate
    
    func loginButton(loginButton: FBSDKLoginButton!,
        didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("Facebook login result: \(result)")
            if !result.isCancelled {
                udacityClient?.loginWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString,
                    completion: { (errorType, userID) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.activityView.stopAnimating()
                        })
                        
                        self.handleLogin(errorType, userID: userID)
                })
            }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("Logged out of Facebook" )
    }
}
