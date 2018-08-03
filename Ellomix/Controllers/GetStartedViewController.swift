//
//  GetStartedViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/10/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth

class GetStartedViewController: UIViewController {
    
    
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    
    override func viewDidLoad() {
        getStartedButton.layer.cornerRadius = getStartedButton.frame.height / 2
        fbButton.layer.cornerRadius = fbButton.frame.height / 2

    }
    
    @IBAction func fbButtonClicked(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email, .userFriends], viewController: self) { loginResult in
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
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toSignUp") {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}
