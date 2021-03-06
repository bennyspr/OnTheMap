//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Benny on 1/9/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: TopViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureColorsAndStyles()
        
        emailTextField.delegate = self
        
        passwordTextField.delegate = self
        
        // fbLoginButton.readPermissions = ["public_profile", "email"];
        
        fbLoginButton.delegate = self
        
        fbLoginButton.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        hideKeyboard()
    }
    
    @IBAction func handleLoginButtonAction(_ sender: UIButton) {
        
        hideKeyboard()
        
        validateEmailAndPassword { (success, items) -> () in
            
            if let items = items, success {
                
                let request = UdacityAPI(urlPath: .Session, httpMethod: .POST)
                
                request.json = [
                    "udacity": [
                        "username": items.email,
                        "password": items.password
                    ]
                ]
                
                self.authUser.fbAccessToken = nil
                
                self.tryToCreateSession(request)
            }
        }
    }
    
    fileprivate func getPublicUserData(_ userID: String) {
        
        let request = UdacityAPI(urlPath: .Users, nextValuesForPath: [userID : .None], httpMethod: .GET)
        
        self.loading.startAnimating()
        
        self.connectionManager.httpRequest(requestAPI: request, completion: { (response, success, errorMessage) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                self.loading.stopAnimating()
                
                if success {
                    
                    if let data = response as? JSON, let user = data["user"] as? JSON, let last_name = user["last_name"] as? String,let first_name = user["first_name"] as? String {
                        
                        self.authUser.firstName = first_name
                        
                        self.authUser.lastName = last_name
                                
                        self.performSegue(withIdentifier: "presentMap", sender: nil)
                        
                    } else {
                        
                        self.presentAlertView(message: "Sorry, there's getting your information. Please try again.")
                    }
                    
                } else if let data = response as? JSON, let message = data["error"] as? String {
                    
                    self.presentAlertView(message: message)
                    
                } else {
                    
                    self.presentAlertView(message: "Sorry, something went wrong.")
                    print("Error Message:\n\(errorMessage)\n")
                }
            })
        })
    }
    
    fileprivate func hideKeyboard() {
        
        view.endEditing(true)
    }
    
    fileprivate func configureColorsAndStyles() {
        
        emailTextField.loginStyleWithPlaceholder("Email")
        
        passwordTextField.loginStyleWithPlaceholder("Password")
        
        loginButton.backgroundColor = .customOrangeredColor()
        
        loginButton.layer.cornerRadius = 5.0
    }
    
    fileprivate func validateEmailAndPassword(_ completion: (Bool, EmailPassword?) -> ()) {
        
        var status = false
        
        if var email = emailTextField.text, let password = passwordTextField.text {
            
            email = email.trim()
            
            if email.isEmpty && password.isEmpty {
                
                presentAlertView(message: "Empty Email and Password")
                
            } else if email.isEmpty {
                
                presentAlertView(message: "Empty Email")
                
            } else if password.isEmpty {
                
                presentAlertView(message: "Empty Password")
                
            } else {
                
                status = true
            }
            
            completion(status, (email, password))
            
        } else {
            
            completion(status, nil)
        }
    }
    
    fileprivate func tryToCreateSession(_ request: RequestAPIProtocol) {
        
        self.loading.startAnimating()
        
        self.connectionManager.httpRequest(requestAPI: request, completion: { (response, success, errorMessage) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                self.loading.stopAnimating()
                
                if success {
                    
                    if let data = response as? JSON, let account = data["account"] as? JSON, let session = data["session"] as? JSON {
                        
                        if let registered = account["registered"] as? Bool, let key = account["key"] as? String, let id = session["id"] as? String, let expiration = session["expiration"] as? String {
                            
                            if registered {
                                
                                self.authUser.accountRegistered = registered
                                
                                self.authUser.accountKey = key
                                
                                self.authUser.sessionID = id
                                
                                self.authUser.sessionExpiration = expiration
                                
                                self.getPublicUserData(key)
                                
                                return
                                
                            } else {
                                
                                self.presentAlertView(message: "Sorry, the user does not have Udacity account.")
                            }
                            
                        } else {
                            
                            self.presentAlertView(message: "Sorry, There was a problem getting the user information. Please try again.")
                        }
                        
                    } else {
                        
                        self.presentAlertView(message: "Sorry, there's a network problem. Please try again.")
                    }
                    
                } else if let data = response as? JSON, let message = data["error"] as? String {
                    
                    self.presentAlertView(message: message)
                    
                } else if let message = errorMessage {
                    
                    self.presentAlertView(withTitle: "Error Message", message: message)
                    
                } else {
                    
                    self.presentAlertView(message: "Sorry, something went wrong.")
                    print("\nSomething went wrong:\n\n\(errorMessage)\n")
                }
                
                FBSDKLoginManager().logOut()
            })
        })
    }
    
    @IBAction func handleSignUpButtonAction(_ sender: UIButton) {
        
        hideKeyboard()
        
        UIApplication.shared.openURL(URL(string: Constant.Udacity.signupURL)!)
    }
    
}

// MARK: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: FBSDKLoginButtonDelegate
extension LoginViewController: FBSDKLoginButtonDelegate {

    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if result.isCancelled {
            return
        }
        
        guard (error == nil) else  {
            
            return
        }
        
        if let token = result.token {
            
            let request = UdacityAPI(urlPath: .Session, httpMethod: .POST)
            
            request.json = [
                "facebook_mobile": [
                    "access_token": token.tokenString
                ]
            ]
            
            self.authUser.fbAccessToken = token.tokenString
            
            self.tryToCreateSession(request)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        
    }
    
}

