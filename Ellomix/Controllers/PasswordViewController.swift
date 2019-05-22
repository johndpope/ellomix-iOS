//
//  PasswordViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/10/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit
import Firebase

class PasswordViewController: UIViewController {
    
    private var FirebaseAPI: FirebaseApi!

    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    var email: String?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        FirebaseAPI = FirebaseApi()
        
        // UI setup
        finishButton.layer.cornerRadius = finishButton.frame.height / 2
        passwordField.underlined()
    }
    
    @IBAction func finishButtonClicked(_ sender: Any) {
        Auth.auth().createUser(withEmail: email!, password: passwordField.text!) { (user, error) in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                        case .invalidEmail:
                            let alert = UIAlertController(title: "Oops", message: "Invalid Email", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            print("Invalid email")
                        case .emailAlreadyInUse:
                            let alert = UIAlertController(title: "Oops", message: "Email Already In Use", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            print("Email in use")
                        case .weakPassword:
                            let alert = UIAlertController(title: "Weak Password", message: "Password should be at least six characters", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        default:
                            print("Create User Error: \(error!)")
                    }
                }
            } else {
                print("Firebase Authenticated succeeded")
                let userID = Auth.auth().currentUser?.uid
                // Do we need to encrypt passwords?
                let password = self.passwordField.text!

                let newUser = EllomixUser(uid: userID!)
                newUser.name = self.name!
                newUser.password = password
                newUser.email = self.email
                Global.sharedGlobal.user = newUser
                self.FirebaseAPI.updateUser(user: newUser)
                self.goToHome()
            }
        }
    }
    
    func goToHome() {
        print("New user created.")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "homeTabController")
        self.present(vc, animated: true, completion: nil)
    }
}
