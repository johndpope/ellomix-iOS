//
//  GetStartedViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/10/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class GetStartedViewController: UIViewController {
    
    @IBOutlet weak var getStartedButton: UIButton!
    
    override func viewDidLoad() {
        getStartedButton.layer.cornerRadius = getStartedButton.frame.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toSignUp") {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}
