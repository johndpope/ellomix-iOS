//
//  EditProfileController.swift
//  Ellomix
//
//  Created by Kevin Avila on 11/13/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class EditProfileController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
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
        
        bioView.delegate = self

        profilePic.circular()
        
        displayProfileInfo()
    }
    
    @IBAction func cancelEdit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveInfo(_ sender: Any) {
        currentUser?.setName(name: nameField.text!)
        currentUser?.setWebsite(website: websiteField.text!)
        currentUser?.setBio(bio: bioView.text!)
        currentUser?.setEmail(email: emailField.text!)
        currentUser?.setGender(gender: genderField.text!)
        currentUser?.setBirthday(birthday: birthdayField.text!)
        currentUser?.setProfilePic(image: profilePic.image!)
        
        FirebaseAPI.updateUser(user: currentUser!)
        FirebaseAPI.updateUserProfilePicture(user: currentUser!, image: profilePic.image!, completion: {})
        Global.sharedGlobal.user = currentUser

        dismiss(animated: true, completion: nil)
    }
    
    func displayProfileInfo() {
        profilePic.image = currentUser?.getProfilePicture().image
        nameField.text = currentUser?.getName()
        websiteField.text = currentUser?.getWebsite()
        bioView.text = currentUser?.getBio()
        emailField.text = currentUser?.getEmail()
        birthdayField.text = currentUser?.getBirthday()
        genderField.text = currentUser?.getGender()
    }
    
    @IBAction func changeProfilePic(_ sender: Any) {
        // What if they haven't allowed permission to access their photo library?
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
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
    
    // UIImagePicker functions
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        profilePic.image = image
        dismiss(animated:true, completion: nil)
    }

    // Date Picker functions
    @IBAction func editingBirthday(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(birthdayValueChanged), for: UIControlEvents.valueChanged)
    }

    @objc func birthdayValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        birthdayField.text = dateFormatter.string(from: sender.date)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 250;
    }
}
