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
    @IBOutlet weak var forgotPassword: UIButton!
    
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showLoadingScreen(parentVC: self, message: "Login in...")
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email, .userFriends], viewController: self) { loginResult in
            
            appDelegate.dismissLoadingScreen()
            switch loginResult {
            case .failed(let error):
                print("Error logging in with Facebook: \(error)")
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                
                /* secondary auth for analytics purposes FB USERS
                 let params = ["fields": "id, first_name, last_name, name, email, picture"]
                 
                 let graphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params)
                 let connection = FBSDKGraphRequestConnection()
                 connection.add(graphRequest, completionHandler: { (connection, result, error) in
                 if error == nil {
                 if let userData = result as? [String:Any] {
                 print(userData)
                 }
                 } else {
                 print("Error Getting Friends \(error)");
                 }
                 })
                 }*/
                
                // -->>>> GET USERS ON SAME APPLICATION ELLOMIX
                //                let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
                //                let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: params)
                //                request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                //
                //                    if error != nil {
                //                        let errorMessage = error.localizedDescription
                //                        /* Handle error */
                //                    }
                //                    else if result.isKindOfClass(NSDictionary){
                //                        /*  handle response */
                //                    }
                //                }
                
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showLoadingScreen(parentVC: self, message: "Login in...")
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            appDelegate.dismissLoadingScreen()
            if let error = error {
                print("Firebase Authentication failed: \(error)")
            }
            // User is signed in
            print("Firebase Authenticated succeeded.")
            self.performSegue(withIdentifier: "toHomeTabBar", sender: self)
        }
    }
// Firebase forgot password functionality
    @IBAction func forgotPasswordTap(_ sender: Any) {
        let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (textField) in
            textField.placeholder = "Enter email address"
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
            let resetEmail = forgotPasswordAlert.textFields?.first?.text
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                if error != nil{
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }else {
                    let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                }
            })
        }))
        //PRESENT ALERT
        self.present(forgotPasswordAlert, animated: true, completion: nil)
    }
}
