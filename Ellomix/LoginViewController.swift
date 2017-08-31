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
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                self.firebaseAuth(credential: credential)
            }
        }
    }
    
    func firebaseAuth(credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                print("Firebase Authentication failed: \(error)")
            }
            // User is signed in
            print("Firebase Authenticated succeeded.")
            self.performSegue(withIdentifier: "toHomeTabBar", sender: self)
        }
    }
}
