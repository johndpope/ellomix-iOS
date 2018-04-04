//
//  ChangePasswordViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 3/18/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit


class ChangePasswordViewController: UIViewController {
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser:EllomixUser?
    
    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var finishButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        FirebaseAPI = FirebaseApi()
        
        FirebaseAPI.getUsersRef()
        .child((currentUser?.uid)!)
        
        
        // UI setup
        finishButton.layer.cornerRadius = finishButton.frame.height / 2
        passwordField.underlined()
        
    }
    
    @IBAction func finishButtonClicked(_ sender: Any) {
        //TODO: finish field
//        Auth.auth().currentUser?.updatePassword(to: <#T##String#>, completion: <#T##UserProfileChangeCallback?##UserProfileChangeCallback?##(Error?) -> Void#>){
//                print("Firebase Authenticated succeeded")
//                let userID = Auth.auth().currentUser?.uid
//            if (self.passwordField === self.confirmPasswordField) {
//                let password = self.passwordField.text!
//                self.FirebaseAPI.updateUser(user: newUser)
//                self.goToHome()
//            
//            } else {
//                print("Passwords do not match..")
//            }
//        }
    }
    
    func goToHome() {
        print("New user created.")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "homeTabController")
        self.present(vc, animated: true, completion: nil)
    }
}
