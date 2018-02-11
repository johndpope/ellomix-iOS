//
//  PasswordViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/10/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController {
    
    override func viewDidLoad() {
        
    }
    
    func goToHome() {
        print("New user created.")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "homeTabController")
        self.present(vc, animated: true, completion: nil)
    }
}
