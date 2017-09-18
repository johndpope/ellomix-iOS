//
//  ProfileController.swift
//  Ellomix
//
//  Created by Kevin Avila on 4/18/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var profileNavBar: UINavigationBar!
    
    var currentUser:User?
    
    override func viewDidLoad() {
        currentUser = Global.sharedGlobal.user
        loadProfile()
    }
    
    func loadProfile() {
        profileNavBar.topItem?.title = "\((currentUser?.getFirstName())!) \((currentUser?.getLastName())!)"
        profilePic.image = currentUser?.getProfilePicture().image
    }
    
}
