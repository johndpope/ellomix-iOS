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

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    private var FirebaseAPI: FirebaseApi!
    
    @IBOutlet weak var contButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        FirebaseAPI = FirebaseApi()
        
        profilePic.layer.cornerRadius = profilePic.frame.size.width/2
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFit
    }

    @IBAction func addProfilePic(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func contButtonClicked(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
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
                let name = self.firstNameField.text! + " " + self.lastNameField.text!
                // Do we need to encrypt passwords?
                let password = self.passwordField.text!
                let email = self.emailField.text!
                let image = self.profilePic.image

                let newUser = EllomixUser(uid: userID!)
                newUser.setName(name: name)
                newUser.setPassword(password: password)
                newUser.setEmail(email: email)
                Global.sharedGlobal.user = newUser
                
                if (image != nil) {
                    newUser.setProfilePic(image: image!)
                    self.FirebaseAPI.updateUserProfilePicture(user: newUser, image: image!) {
                        self.FirebaseAPI.updateUser(user: newUser)
                        self.goToHome()
                    }
                } else {
                    self.FirebaseAPI.updateUser(user: newUser)
                    self.goToHome()
                }
            }
        }
    }
    
    func goToHome() {
        print("New user created.")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "homeTabController")
        self.present(vc, animated: true, completion: nil)
    }

    // UIImagePicker functions
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        profilePic.image = image
        dismiss(animated:true, completion: nil)
    }
}
