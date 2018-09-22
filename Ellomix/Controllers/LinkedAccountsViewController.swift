//
//  LinkedAccountsViewController.swift
//  Ellomix
//
//  Created by akshay.vyas on 7/19/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import Foundation
import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth

// This is for linking accounts if a person has already logged in with one account.
// FACEBOOK and SPOTIFY

class LinkedAccountViewController: UIViewController {
    
    @IBOutlet weak var spotifyButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        spotifyButton.layer.cornerRadius = spotifyButton.frame.height / 2
        facebookButton.layer.cornerRadius = facebookButton.frame.height / 2
    }

    
// LOGIN WITH FACEBOOK AND ATTACHED LINKED ACCOUNT
    
// SPOTIFY AUTHENTICATION
    // --> link to spotify loginview controller or implement new login here?
}


