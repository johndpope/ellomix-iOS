//
//  ViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 12/19/16.
//  Copyright © 2016 Akshay Vyas. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // UI setup
        emailField.underlined()
        passwordField.underlined()
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        fbButton.layer.cornerRadius = fbButton.frame.height / 2
    }
    
    @IBAction func fbButtonClicked(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile, .email, .userFriends], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                
               /* //NSD2
                let params = ["fields":"..."]
                let graphRequest = GraphRequest(graphPath: "me", parameters: params)
                graphRequest.start {
                    (urlResponse, requestResult) in
                    switch requestResult {
                    case .failed(let error):
                        print("error in graph request:", error)
                        break
                        // Handle the result's error
                        
                    case .success(let graphResponse):
                        if let responseDictionary = graphResponse.dictionaryValue {
                            let json = JSON(responseDictionary)
                            let id = json["id"].string!
                            successBlock(true, json, accessToken.authenticationToken ,id)
                            print(responseDictionary["name"])
                            print(responseDictionary["email"])
                            print(responseDictionary["user_friends"])

                        }
                    }
                    
                }*/
                // NSD
                let params = ["fields" : "email, name"]
                let graphRequest = GraphRequest(graphPath: "me/friends", parameters: params)
                graphRequest.start { (urlResponse, requestResult) in
                    switch requestResult {
                    case .failed(let error):
                        print("error in graph request:", error)
                        break
                    case .success(let graphResponse):
                        if let responseDictionary = graphResponse.dictionaryValue {
                            print(responseDictionary)
                        }
                    }
                }
                
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        print("Firebase Authentication failed: \(error)")
                    }
                    // User is signed in
                    print("Firebase Authenticated succeeded.")
                    self.performSegue(withIdentifier: "toHomeTabBar", sender: self)
                }
            }
        }
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        let email = emailField.text!
        let password = passwordField.text!
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Firebase Authentication failed: \(error)")
            }
            // User is signed in
            print("Firebase Authenticated succeeded.")
            self.performSegue(withIdentifier: "toHomeTabBar", sender: self)
        }
    }

}
