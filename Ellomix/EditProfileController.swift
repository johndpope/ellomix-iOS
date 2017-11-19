//
//  EditProfileController.swift
//  Ellomix
//
//  Created by Kevin Avila on 11/13/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class EditProfileController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var websiteField: UITextField!
    @IBOutlet weak var bioView: UITextView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var birthdayField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser:EllomixUser?
    var genderOptions = ["Not Specified", "Male", "Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = Global.sharedGlobal.user
        FirebaseAPI = FirebaseApi()
        
        let pickerView = UIPickerView()
        genderField.inputView = pickerView
        pickerView.delegate = self
        
        profilePic.layer.cornerRadius = profilePic.frame.size.width/2
        profilePic.clipsToBounds = true
        
        displayProfileInfo()
    }
    
    @IBAction func cancelEdit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveInfo(_ sender: Any) {
        currentUser?.setName(name: nameField.text!)
        currentUser?.setWebsite(website: websiteField.text!)
        currentUser?.setBio(bio: bioView.text )
        currentUser?.setEmail(email: emailField.text!)
        currentUser?.setGender(gender: genderField.text!)
        
        // Update user on Firebase

        
        dismiss(animated: true, completion: nil)
    }
    
    func displayProfileInfo() {
        profilePic.image = currentUser?.getProfilePicture().image
        nameField.text = currentUser?.getName()
        websiteField.text = currentUser?.getWebsite()
        bioView.text = currentUser?.getBio()
        emailField.text = currentUser?.getEmail()
        genderField.text = currentUser?.getGender()
    }
    
    @IBAction func changeProfilePic(_ sender: Any) {
        
    }
    
    // Picker View functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderField.text = genderOptions[row]
    }
}
