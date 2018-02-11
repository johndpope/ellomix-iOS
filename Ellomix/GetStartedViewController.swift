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
}
