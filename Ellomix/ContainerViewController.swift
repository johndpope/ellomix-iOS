//
//  ContainerViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 12/3/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    
    @IBOutlet weak var baseContainerView: UIView!
    @IBOutlet weak var playBarView: UIView!
    
    override func viewDidLoad() {
        playBarView.isHidden = true
    }
}
