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

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser:EllomixUser?
    
    @IBOutlet weak var contButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = Global.sharedGlobal.user
        FirebaseAPI = FirebaseApi()
        
        profilePic.layer.cornerRadius = profilePic.frame.size.width/2
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFit
    }

    @IBAction func addProfilePic(_ sender: Any) {
        // What if they haven't allowed permission to access their photo library?
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
            }
            else {
                // User is signed in
                print("Firebase Authenticated succeeded")
                
                let userID = Auth.auth().currentUser?.uid
                self.FirebaseAPI.getUsersRef().child(userID!).setValue(["email" : self.emailField.text, "name" : self.nameField.text]) // Need photoUrl or else nil error occurs
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "homeTabController")
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    // UIImagePicker functions
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        profilePic.image = image
        dismiss(animated:true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
