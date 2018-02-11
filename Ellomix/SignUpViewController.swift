//
//  SignUpViewController.swift
//  Ellomix
//
//  Created by Steven  Villarreal on 12/18/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var emailPhoneField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var contButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // UI setup
        contButton.layer.cornerRadius = contButton.frame.height / 2
        emailPhoneField.underlined()
        nameField.underlined()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toPassword") {
            let passwordVC = segue.destination as! PasswordViewController
            passwordVC.email = emailPhoneField.text!
            passwordVC.name = nameField.text!
        }
    }
    
}
