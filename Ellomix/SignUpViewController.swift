//
//  SignUpViewController.swift
//  Ellomix
//
//  Created by Steven  Villarreal on 12/18/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    private var FirebaseAPI: FirebaseApi!
    
    @IBOutlet weak var emailPhoneField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var contButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        self.hideKeyboardWhenTappedAround()
        
        // UI setup
        contButton.layer.cornerRadius = contButton.frame.height / 2
        emailPhoneField.underlined()
        nameField.underlined()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toPassword") {
            let passwordVC = segue.destination as! PasswordViewController
        }
    }
    
//    @IBAction func contButtonClicked(_ sender: Any) {
//        Auth.auth().createUser(withEmail: emailPhoneField.text!, password: passwordField.text!) { (user, error) in
//            if error != nil {
//                if let errCode = AuthErrorCode(rawValue: error!._code) {
//                    switch errCode {
//                        case .invalidEmail:
//                            let alert = UIAlertController(title: "Oops", message: "Invalid Email", preferredStyle: .alert)
//                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//                            alert.addAction(action)
//                            self.present(alert, animated: true, completion: nil)
//                            print("Invalid email")
//                        case .emailAlreadyInUse:
//                            let alert = UIAlertController(title: "Oops", message: "Email Already In Use", preferredStyle: .alert)
//                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//                            alert.addAction(action)
//                            self.present(alert, animated: true, completion: nil)
//                            print("Email in use")
//                        case .weakPassword:
//                            let alert = UIAlertController(title: "Weak Password", message: "Password should be at least six characters", preferredStyle: .alert)
//                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//                            alert.addAction(action)
//                            self.present(alert, animated: true, completion: nil)
//                        default:
//                            print("Create User Error: \(error!)")
//                    }
//                }
//            } else {
//                print("Firebase Authenticated succeeded")
//                let userID = Auth.auth().currentUser?.uid
//                let name = self.firstNameField.text! + " " + self.lastNameField.text!
//                // Do we need to encrypt passwords?
//                let password = self.passwordField.text!
//                let email = self.emailField.text!
//                let image = self.profilePic.image
//
//                let newUser = EllomixUser(uid: userID!)
//                newUser.setName(name: name)
//                newUser.setPassword(password: password)
//                newUser.setEmail(email: email)
//                Global.sharedGlobal.user = newUser
//
//                if (image != nil) {
//                    newUser.setProfilePic(image: image!)
//                    self.FirebaseAPI.updateUserProfilePicture(user: newUser, image: image!) {
//                        self.FirebaseAPI.updateUser(user: newUser)
//                        self.goToHome()
//                    }
//                } else {
//                    self.FirebaseAPI.updateUser(user: newUser)
//                    self.goToHome()
//                }
//            }
//        }
//    }
    
}
